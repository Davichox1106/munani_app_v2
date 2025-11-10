import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/auto_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'debug_auth_simple.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/employees/presentation/pages/administrators_page.dart';
import 'features/employees/presentation/pages/employees_store_page.dart';
import 'features/employees/presentation/pages/employees_warehouse_page.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'features/sync/presentation/bloc/sync_event.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/reports/presentation/pages/daily_sales_report_page.dart';
import 'features/reports/presentation/pages/sales_report_page.dart';
import 'features/reports/presentation/pages/purchases_report_page.dart';
import 'features/reports/presentation/pages/transfers_report_page.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'core/constants/app_routes.dart';

// Comentario de prueba - Claude Code puede editar archivos correctamente
void main() async {
  // Capturar errores no manejados (como los de Supabase sin conexión)
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Manejar errores de Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      // Solo registrar, no lanzar excepción
      FlutterError.presentError(details);
      debugPrint('🔴 Flutter Error: ${details.exceptionAsString()}');
    };

    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');

    // Inicializar Supabase con configuración tolerante a fallos de red
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // Deshabilitar auto-refresh si falla para evitar excepciones no manejadas
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    // Inicializar sistema de logging (A09 - OWASP)
    await AppLogger.initialize();

    // Inicializar inyección de dependencias
    await di.init();

    runApp(const MyApp());
  }, (error, stack) {
    // Capturar errores globales no manejados (como AuthRetryableFetchException)
    // Solo registrarlos sin crashear la app
    debugPrint('🔴 Error global no manejado: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AutoSyncService _autoSyncService;

  @override
  void initState() {
    super.initState();

    // Registrar observer para detectar cambios de lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Obtener servicio de sincronización automática
    _autoSyncService = di.sl<AutoSyncService>();

    // ⏰ SINCRONIZACIÓN PERIÓDICA cada 5 minutos
    _autoSyncService.startPeriodicSync();

    debugPrint('🚀 AutoSync inicializado');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 📱 SINCRONIZAR cuando la app vuelve del background
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App retomada, sincronizando...');
      _autoSyncService.onAppResumed();
    }
  }

  @override
  void dispose() {
    // Limpiar recursos
    _autoSyncService.stopPeriodicSync();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<SyncBloc>()
            ..add(const SyncCheckConnection())
            ..add(const SyncStartAutoSync(interval: Duration(seconds: 30))),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        // Configurar rutas para deep links
        routes: {
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/reset-password': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return ResetPasswordPage(
              accessToken: args?['access_token'],
              refreshToken: args?['refresh_token'],
            );
          },
          // Rutas de empleados
          '/administrators': (context) => const AdministratorsPage(),
          '/employees/store': (context) => const EmployeesStorePage(),
          '/employees/warehouse': (context) => const EmployeesWarehousePage(),
          // Rutas de reportes
          AppRoutes.reports: (context) => const ReportsPage(),
          AppRoutes.dailySalesReport: (context) => BlocProvider(
                create: (context) => di.sl<ReportsBloc>(),
                child: const DailySalesReportPage(),
              ),
          AppRoutes.salesReport: (context) => BlocProvider(
                create: (context) => di.sl<ReportsBloc>(),
                child: const SalesReportPage(),
              ),
          AppRoutes.purchasesReport: (context) => BlocProvider(
                create: (context) => di.sl<ReportsBloc>(),
                child: const PurchasesReportPage(),
              ),
          AppRoutes.transfersReport: (context) => BlocProvider(
                create: (context) => di.sl<ReportsBloc>(),
                child: const TransfersReportPage(),
              ),
        },
        // Manejar deep links
        onGenerateRoute: (settings) {
          if (settings.name == '/reset-password') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                accessToken: args?['access_token'],
                refreshToken: args?['refresh_token'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Wrapper que maneja la navegación basada en el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasTriggeredInitialSync = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        AppLogger.debug('🔍 AuthWrapper: Estado actual = ${state.runtimeType}');

        // Ejecutar depuración de autenticación
        DebugAuthSimple.debugAuth();

        // Mostrar splash mientras se verifica autenticación
        if (state is AuthInitial || state is AuthLoading) {
          AppLogger.debug('   → Mostrando splash de carga');
          return Scaffold(
            backgroundColor: AppColors.background, // Fondo caramelo
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Munani
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.accentGold,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/munani.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Si no se encuentra la imagen, mostrar icono
                          return Icon(
                            Icons.favorite,
                            size: 60,
                            color: AppColors.accentGold,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Nombre de la app
                  Text(
                    'Munani',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Eslogan
                  Text(
                    'Tu tienda de confianza',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Barra de progreso
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primaryLightCaramel,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.textLight,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          AppLogger.debug('   → Usuario autenticado, mostrando HomePage');

          if (!_hasTriggeredInitialSync) {
            _hasTriggeredInitialSync = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final autoSyncService = di.sl<AutoSyncService>();
              autoSyncService.updateUserRole(
                state.user.role,
                userId: state.user.id,
              );
              autoSyncService.initializeApp();
            });
          }

          return const HomePage();
        }

        if (state is AuthError) {
          AppLogger.debug('   → Error de autenticación, mostrando LoginPage con mensaje');
          _hasTriggeredInitialSync = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            di.sl<AutoSyncService>().updateUserRole(null, userId: null);
          });
        return LoginPage(initialErrorMessage: state.message);
        }

        AppLogger.debug('   → Usuario NO autenticado, mostrando LoginPage');
        _hasTriggeredInitialSync = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          di.sl<AutoSyncService>().updateUserRole(null, userId: null);
        });
        return const LoginPage();
      },
    );
  }
}
