import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:munani_app/core/utils/app_logger.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/create_user.dart' as use_cases;
import '../../domain/usecases/deactivate_user.dart' as use_cases;
import '../../domain/usecases/get_all_users.dart';
import '../../domain/usecases/update_user.dart' as use_cases;
import '../../domain/services/location_name_service.dart';
import '../../domain/entities/enriched_user.dart';
import '../../domain/entities/user.dart' as user_management;
import '../../../auth/domain/entities/user.dart' as auth_user;
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

/// BLoC para gestión de usuarios
///
/// Maneja el estado de la interfaz de administración de usuarios
/// Solo accesible por administradores
class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllUsers getAllUsers;
  final use_cases.CreateUser createUser;
  final use_cases.UpdateUser updateUser;
  final use_cases.DeactivateUser deactivateUser;
  final UserRepository repository;
  final GetCurrentUserUseCase getCurrentUser;
  final LocationNameService locationNameService;

  UserManagementBloc({
    required this.getAllUsers,
    required this.createUser,
    required this.updateUser,
    required this.deactivateUser,
    required this.repository,
    required this.getCurrentUser,
    required this.locationNameService,
  }) : super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeactivateUser>(_onDeactivateUser);
  }

  /// Cargar todos los usuarios con stream reactivo
  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());

    // Inicializar servicio de nombres de ubicaciones
    await locationNameService.initialize();

    await emit.forEach(
      repository.watchAllUsers(),
      onData: (users) {
        final enrichedUsers = _enrichUsers(users);
        return EnrichedUsersLoaded(enrichedUsers);
      },
      onError: (error, stackTrace) => UserManagementError(error.toString()),
    );
  }

  /// Crear un nuevo usuario
  Future<void> _onCreateUser(
    CreateUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());

    // Verificar permisos de administrador ANTES de crear usuario
    AppLogger.debug('🔍 Verificando permisos de administrador...');
    
    // Obtener usuario actual para verificar permisos
    final currentUserResult = await getCurrentUser();
    final currentUser = currentUserResult.fold<auth_user.User?>(
      (failure) {
        AppLogger.error('❌ Error obteniendo usuario actual: ${failure.message}');
        emit(
          UserManagementError('No se pudo verificar permisos: ${failure.message}'),
        );
        return null;
      },
      (auth_user.User user) {
        if (!user.isAdmin) {
          AppLogger.warning('❌ Usuario actual NO es administrador: ${user.role}');
          emit(UserManagementError('Solo los administradores pueden crear usuarios'));
          return null;
        }

        AppLogger.info('✅ Usuario actual ES administrador - procediendo con creación');
        return user;
      },
    );

    if (currentUser == null) {
      return;
    }

    // Si llegamos aquí, el usuario es admin, proceder con la creación
    final result = await createUser(
      email: event.email,
      password: event.password,
      name: event.name,
      role: event.role,
      assignedLocationId: event.assignedLocationId,
      assignedLocationType: event.assignedLocationType,
    );

    await result.fold<Future<void>>(
      (failure) async {
        // Log de seguridad: Creación de usuario fallida
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userCreation,
              userId: admin.id,
              userEmail: admin.email,
              targetResource: event.email,
              action: 'CREATE_USER',
              success: false,
              details: 'Error creando usuario: ${failure.message}',
              metadata: {'targetRole': event.role},
            );
          },
        );

        if (!emit.isDone) {
          emit(UserManagementError(failure.message));
        }
      },
      (user) async {
        // Log de seguridad: Usuario creado exitosamente
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userCreation,
              userId: admin.id,
              userEmail: admin.email,
              targetUserId: user.id,
              targetResource: user.email,
              action: 'CREATE_USER',
              success: true,
              details: 'Nuevo usuario creado: ${user.name} con rol ${user.role}',
              metadata: {
                'targetRole': user.role,
                'targetName': user.name,
                'assignedLocation': user.assignedLocationId,
              },
            );
          },
        );

        if (!emit.isDone) {
          emit(UserCreated(user: user));
        }
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Actualizar un usuario existente
  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());

    final result = await updateUser(
      userId: event.userId,
      name: event.name,
      role: event.role,
      assignedLocationId: event.assignedLocationId,
      assignedLocationType: event.assignedLocationType,
      isActive: event.isActive,
    );

    await result.fold<Future<void>>(
      (failure) async {
        // Log de seguridad: Actualización fallida
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userModification,
              userId: admin.id,
              userEmail: admin.email,
              targetUserId: event.userId,
              action: 'UPDATE_USER',
              success: false,
              details: 'Error actualizando usuario: ${failure.message}',
            );
          },
        );

        if (!emit.isDone) {
          emit(UserManagementError(failure.message));
        }
      },
      (user) async {
        // Log de seguridad: Usuario actualizado exitosamente
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userModification,
              userId: admin.id,
              userEmail: admin.email,
              targetUserId: user.id,
              targetResource: user.email,
              action: 'UPDATE_USER',
              success: true,
              details: 'Usuario actualizado: ${user.name}',
              metadata: {
                'newRole': user.role,
                'newLocation': user.assignedLocationId,
                'isActive': user.isActive,
              },
            );
          },
        );

        if (!emit.isDone) {
          emit(UserUpdated(user: user));
        }
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Desactivar un usuario
  Future<void> _onDeactivateUser(
    DeactivateUser event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserManagementLoading());

    final result = await deactivateUser(event.userId);

    await result.fold<Future<void>>(
      (failure) async {
        // Log de seguridad: Desactivación fallida
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userDeletion,
              userId: admin.id,
              userEmail: admin.email,
              targetUserId: event.userId,
              action: 'DEACTIVATE_USER',
              success: false,
              details: 'Error desactivando usuario: ${failure.message}',
            );
          },
        );

        if (!emit.isDone) {
          emit(UserManagementError(failure.message));
        }
      },
      (_) async {
        // Log de seguridad: Usuario desactivado exitosamente
        final currentUser = await getCurrentUser();
        await currentUser.fold(
          (f) async {},
          (admin) async {
            await AppLogger.logSecurityEvent(
              eventType: SecurityEventType.userDeletion,
              userId: admin.id,
              userEmail: admin.email,
              targetUserId: event.userId,
              action: 'DEACTIVATE_USER',
              success: true,
              details: 'Usuario desactivado exitosamente',
            );
          },
        );

        if (!emit.isDone) {
          emit(UserDeactivated());
        }
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Enriquecer usuarios con nombres de ubicaciones
  List<EnrichedUser> _enrichUsers(List<user_management.User> users) {
    return users.map((user) {
      final locationName = locationNameService.getLocationName(
        user.assignedLocationId,
        user.assignedLocationType,
      );
      return EnrichedUser.fromUser(user, locationName);
    }).toList();
  }
}

