import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/rate_limiter_service.dart';
import 'auth_event.dart';
import 'auth_state.dart' as bloc_state;
import 'package:munani_app/core/utils/app_logger.dart';

/// BLoC de autenticación
///
/// Maneja todos los eventos relacionados con autenticación y emite estados correspondientes.
/// Sigue el patrón BLoC para separar la lógica de negocio de la UI.
///
/// Características de seguridad:
/// - Rate limiting para prevenir ataques de fuerza bruta
/// - Bloqueo temporal después de múltiples intentos fallidos
/// - Logging de eventos de seguridad
class AuthBloc extends Bloc<AuthEvent, bloc_state.AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  final RateLimiterService rateLimiterService;

  late StreamSubscription<AuthState> _authStateSubscription;
  bool _isLoggingOut = false; // Flag para evitar ciclo infinito

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.rateLimiterService,
  }) : super(const bloc_state.AuthInitial()) {
    // Registrar handlers de eventos
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);

    // Escuchar cambios automáticos de autenticación de Supabase
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        AppLogger.debug('🔄 AuthBloc: Cambio de estado de autenticación detectado');
        AppLogger.debug('   Evento: ${data.event}');
        AppLogger.debug('   Usuario: ${data.session?.user.email}');
        
        if (data.event == AuthChangeEvent.signedOut && !_isLoggingOut) {
          AppLogger.debug('🚪 Usuario deslogueado externamente');
          // Enviar evento para que el BLoC maneje el cambio de estado
          add(const AuthCheckRequested());
        } else if (data.event == AuthChangeEvent.signedIn) {
          AppLogger.info('✅ Usuario logueado automáticamente');
          add(const AuthCheckRequested());
        }
      },
      onError: (error) {
        // Manejar errores de red silenciosamente (sin conexión, timeouts, etc.)
        AppLogger.error('⚠️ AuthBloc: Error en auth state stream (ignorado): $error');
        // No lanzar la excepción, solo registrarla
      },
      cancelOnError: false, // Continuar escuchando incluso si hay errores
    );
  }

  /// Handler: Verificar estado de autenticación
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    AppLogger.debug('🔍 AuthBloc: Verificando estado de autenticación...');
    emit(const bloc_state.AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) {
        AppLogger.error('❌ AuthBloc: Usuario NO autenticado - ${failure.message}');
        emit(const bloc_state.AuthUnauthenticated());
      },
      (user) {
        AppLogger.info('✅ AuthBloc: Usuario autenticado - ${user.email}');
        emit(bloc_state.AuthAuthenticated(user: user));
      },
    );
  }

  /// Handler: Login con Rate Limiting
  ///
  /// Previene ataques de fuerza bruta mediante:
  /// - Verificación de bloqueo antes de intentar login
  /// - Registro de intentos fallidos
  /// - Bloqueo temporal después de múltiples fallos
  /// - Limpieza de registros en login exitoso
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    emit(const bloc_state.AuthLoading());

    final sanitizedEmail = InputSanitizer.sanitizeEmail(event.email);
    final email = sanitizedEmail.toLowerCase().trim();
    AppLogger.debug('🔐 Login iniciado para: $email');

    final safetyWarning = InputSanitizer.firstSafetyWarning([sanitizedEmail]);
    if (email.isEmpty || safetyWarning != null) {
      AppLogger.warning('⚠️ Login bloqueado por entrada inválida: ${event.email}');
      emit(bloc_state.AuthError(
        message: safetyWarning ?? 'Email inválido. Verifica e intenta nuevamente.',
      ));
      return;
    }

    final isBlocked = await rateLimiterService.isBlocked(email);
    if (isBlocked) {
      final remainingMinutes = await rateLimiterService.getRemainingBlockTime(email);
      final errorMessage = 'Demasiados intentos fallidos. '
          'Tu cuenta está temporalmente bloqueada. '
          'Intenta nuevamente en $remainingMinutes minuto(s).';

      AppLogger.warning('🚫 Login bloqueado por rate limiting: $email ($remainingMinutes min restantes)');

      // Log de seguridad: Bloqueo por rate limiting
      await AppLogger.logSecurityEvent(
        eventType: SecurityEventType.loginBlocked,
        userId: 'unknown',
        userEmail: email,
        success: false,
        details: 'Usuario bloqueado por $remainingMinutes minutos debido a múltiples intentos fallidos',
        metadata: {'remainingMinutes': remainingMinutes},
      );

      emit(bloc_state.AuthError(message: errorMessage));
      return;
    }

    final result = await loginUseCase(
      LoginParams(
        email: email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async {
        AppLogger.error('❌ Login falló: ${failure.message}');

        final nowBlocked = await rateLimiterService.recordFailedAttempt(email);
        final failedAttempts = await rateLimiterService.getFailedAttempts(email);

        String errorMessage;
        if (failure is InvalidCredentialsFailure || failure is AuthFailure) {
          errorMessage = 'Email o contraseña incorrectos.';
        } else {
          errorMessage = 'No se pudo iniciar sesión. Intenta nuevamente.';
        }

        if (nowBlocked) {
          final blockTime = await rateLimiterService.getRemainingBlockTime(email);
          errorMessage += '\n\nCuenta bloqueada temporalmente por $blockTime minuto(s).';

          AppLogger.warning('⛔ Usuario $email BLOQUEADO por múltiples intentos fallidos');
        } else if (failedAttempts > 0) {
          final remaining = RateLimiterService.maxAttempts - failedAttempts;
          errorMessage += '\n\nIntentos restantes antes de bloqueo: $remaining';

          AppLogger.warning('⚠️ Intento fallido $failedAttempts/${RateLimiterService.maxAttempts} para $email');
        }

        // Log de seguridad: Login fallido
        await AppLogger.logSecurityEvent(
          eventType: SecurityEventType.loginAttempt,
          userId: 'unknown',
          userEmail: email,
          success: false,
          details: 'Credenciales inválidas - ${failure.message}',
          metadata: {
            'failedAttempts': failedAttempts,
            'remainingAttempts': RateLimiterService.maxAttempts - failedAttempts,
            'nowBlocked': nowBlocked,
          },
        );

        emit(bloc_state.AuthError(message: errorMessage));
      },
      (user) async {
        await rateLimiterService.recordSuccessfulAttempt(email);

        AppLogger.info('✅ Login exitoso para: ${user.name} (${user.role})');

        // Log de seguridad: Login exitoso
        await AppLogger.logSecurityEvent(
          eventType: SecurityEventType.loginAttempt,
          userId: user.id,
          userEmail: user.email,
          success: true,
          details: 'Login exitoso - Rol: ${user.role}',
          metadata: {
            'role': user.role,
            'userName': user.name,
          },
        );

        emit(bloc_state.AuthAuthenticated(user: user));
      },
    );
  }

  /// Handler: Registro
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    emit(const bloc_state.AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      ),
    );

    result.fold(
      (failure) => emit(bloc_state.AuthError(message: failure.message)),
      (user) {
        // Emisión exitosa: usuario registrado
        emit(const bloc_state.AuthRegistered());
        // Luego autenticar automáticamente
        emit(bloc_state.AuthAuthenticated(user: user));
      },
    );
  }

  /// Handler: Logout
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    _isLoggingOut = true; // Activar flag

    // Capturar datos del usuario antes del logout
    String? userId;
    String? userEmail;
    if (state is bloc_state.AuthAuthenticated) {
      final user = (state as bloc_state.AuthAuthenticated).user;
      userId = user.id;
      userEmail = user.email;
    }

    emit(const bloc_state.AuthLoading());

    final result = await logoutUseCase();

    await result.fold<Future<void>>(
      (failure) async {
        _isLoggingOut = false;
        emit(bloc_state.AuthError(message: failure.message));
      },
      (_) async {
        _isLoggingOut = false;

        // Log de seguridad: Logout exitoso
        if (userId != null) {
          await AppLogger.logSecurityEvent(
            eventType: SecurityEventType.logout,
            userId: userId,
            userEmail: userEmail,
            success: true,
            details: 'Usuario cerró sesión correctamente',
          );
        }

        AppLogger.info('🚪 Logout exitoso');
        emit(const bloc_state.AuthUnauthenticated());
      },
    );
  }

  /// Handler: Actualizar perfil
  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    emit(const bloc_state.AuthLoading());

    final result = await authRepository.updateProfile(
      name: event.name,
      assignedLocationId: event.assignedLocationId,
      assignedLocationType: event.assignedLocationType,
    );

    result.fold(
      (failure) => emit(bloc_state.AuthError(message: failure.message)),
      (user) => emit(bloc_state.AuthProfileUpdated(user: user)),
    );
  }

  /// Handler: Cambiar contraseña
  Future<void> _onAuthChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    emit(const bloc_state.AuthLoading());

    final result = await authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(bloc_state.AuthError(message: failure.message)),
      (_) async {
        // Obtener usuario actualizado
        final userResult = await getCurrentUserUseCase();
        userResult.fold(
          (failure) => emit(bloc_state.AuthError(message: failure.message)),
          (user) => emit(bloc_state.AuthProfileUpdated(
            user: user,
            message: 'Contraseña actualizada exitosamente',
          )),
        );
      },
    );
  }

  /// Handler: Reset de contraseña
  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<bloc_state.AuthState> emit,
  ) async {
    emit(const bloc_state.AuthLoading());

    final result = await authRepository.resetPassword(email: event.email);

    result.fold(
      (failure) => emit(bloc_state.AuthError(message: failure.message)),
      (_) => emit(const bloc_state.AuthPasswordResetSent()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
