import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/user.dart' as user_management;
import '../../domain/services/location_name_service.dart';
import '../../../locations/domain/repositories/location_repository.dart';
import '../../../employees/domain/repositories/administrator_repository.dart';
import '../../../employees/domain/repositories/employee_store_repository.dart';
import '../../../employees/domain/repositories/employee_warehouse_repository.dart';
import '../bloc/user_management_bloc.dart';
import '../bloc/user_management_event.dart';

/// Página de formulario para crear/editar usuarios
///
/// Solo accesible por Administradores
class UserFormPage extends StatefulWidget {
  final user_management.User? user; // null = crear, != null = editar
  final UserManagementBloc? userManagementBloc; // BLoC opcional

  const UserFormPage({super.key, this.user, this.userManagementBloc});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedRole = 'customer';
  bool _assignStoreToAdmin = false;
  String? _selectedLocationId;
  String? _selectedLocationType;
  bool _obscurePassword = true;

  // Servicio de ubicaciones
  late final LocationNameService _locationNameService;
  List<Map<String, dynamic>> _availableLocations = [];
  bool _isLoadingLocations = false;

  // Autocompletado desde tablas de empleados
  String? _selectedEmployeeSource; // 'administrators', 'employees_store', 'employees_warehouse'
  bool _isSearchingEmployee = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    
    // Inicializar servicio de ubicaciones
    _locationNameService = di.sl<LocationNameService>();

    // Si estamos editando, llenar los campos
    if (isEditing) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
      _selectedLocationId = widget.user!.assignedLocationId;
      _selectedLocationType = widget.user!.assignedLocationType;

      if (_selectedRole == 'admin' && _selectedLocationType == 'store') {
        _assignStoreToAdmin = true;
      }
    }

    // Cargar ubicaciones si es necesario
    if (_selectedRole == 'store_manager' ||
        _selectedRole == 'warehouse_manager' ||
        (_selectedRole == 'admin' && _assignStoreToAdmin)) {
      _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    final needsStoresForAdmin = _selectedRole == 'admin' && _assignStoreToAdmin;
    if (!(_selectedRole == 'store_manager' ||
        _selectedRole == 'warehouse_manager' ||
        needsStoresForAdmin)) {
      return;
    }

    setState(() {
      _isLoadingLocations = true;
    });

    try {
      // Inicializar el servicio si no está inicializado
      await _locationNameService.initialize();
      
      // Obtener ubicaciones según el rol
      if (_selectedRole == 'store_manager' || needsStoresForAdmin) {
        // Obtener tiendas del repositorio
        final locationRepository = di.sl<LocationRepository>();
        final storesResult = await locationRepository.getAllStores();
        
        storesResult.fold(
          (failure) => AppLogger.error('Error cargando tiendas: ${failure.message}'),
          (stores) {
            setState(() {
              _availableLocations = stores.map((store) => {
                'id': store.id,
                'name': store.name,
                'type': 'store',
              }).toList();
            });
          },
        );
      } else if (_selectedRole == 'warehouse_manager') {
        // Obtener almacenes del repositorio
        final locationRepository = di.sl<LocationRepository>();
        final warehousesResult = await locationRepository.getAllWarehouses();
        
        warehousesResult.fold(
          (failure) => AppLogger.error('Error cargando almacenes: ${failure.message}'),
          (warehouses) {
            setState(() {
              _availableLocations = warehouses.map((warehouse) => {
                'id': warehouse.id,
                'name': warehouse.name,
                'type': 'warehouse',
              }).toList();
            });
          },
        );
      }
    } catch (e) {
      AppLogger.error('Error cargando ubicaciones: $e');
    } finally {
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  /// Busca un empleado por email en la tabla seleccionada y autocompleta los campos
  Future<void> _searchEmployeeByEmail(String email) async {
    if (email.trim().isEmpty || _selectedEmployeeSource == null) {
      return;
    }

    setState(() => _isSearchingEmployee = true);

    try {
      dynamic employee;

      switch (_selectedEmployeeSource) {
        case 'administrators':
          final repo = di.sl<AdministratorRepository>();
          employee = await repo.getByEmail(email);
          if (employee != null) {
            _selectedRole = 'admin';
          }
          break;
        case 'employees_store':
          final repo = di.sl<EmployeeStoreRepository>();
          employee = await repo.getByEmail(email);
          if (employee != null) {
            _selectedRole = 'store_manager';
            _loadLocations();
          }
          break;
        case 'employees_warehouse':
          final repo = di.sl<EmployeeWarehouseRepository>();
          employee = await repo.getByEmail(email);
          if (employee != null) {
            _selectedRole = 'warehouse_manager';
            _loadLocations();
          }
          break;
      }

      if (employee != null) {
        setState(() {
          _nameController.text = employee.name;
          _phoneController.text = employee.phone ?? '';
          _addressController.text = employee.address ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Datos autocompletados desde el registro de empleado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontró empleado con el email: $email'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar empleado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingEmployee = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresLocation = _selectedRole == 'store_manager' ||
        _selectedRole == 'warehouse_manager' ||
        (_selectedRole == 'admin' && _assignStoreToAdmin);
    final showLocationToggle = _selectedRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Información básica
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Autocompletar desde empleados (solo al crear)
            if (!isEditing) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Autocompletar desde empleados registrados',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEmployeeSource,
                        decoration: InputDecoration(
                          labelText: 'Buscar en',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'administrators',
                            child: Text('Administradores'),
                          ),
                          DropdownMenuItem(
                            value: 'employees_store',
                            child: Text('Empleados de Tienda'),
                          ),
                          DropdownMenuItem(
                            value: 'employees_warehouse',
                            child: Text('Empleados de Almacén'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedEmployeeSource = value);
                        },
                      ),
                      if (_selectedEmployeeSource != null) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email del empleado',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  suffixIcon: _isSearchingEmployee
                                      ? Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : null,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isSearchingEmployee
                                  ? null
                                  : () => _searchEmployeeByEmail(_emailController.text),
                              icon: Icon(Icons.search),
                              label: Text('Buscar'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                hintText: 'Ej: Juan Pérez',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Email (solo al editar o crear sin autocompletado)
            if (isEditing || _selectedEmployeeSource == null) ...[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'usuario@ejemplo.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isEditing, // No se puede cambiar el email al editar
                validator: Validators.email,
              ),
              SizedBox(height: 16),
            ],

            // Contraseña (solo al crear)
            if (!isEditing) ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Debe cumplir las políticas de seguridad',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  final result = PasswordValidator.validate(value);
                  if (!result.isValid) {
                    return result.errors.first;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              PasswordStrengthIndicator(
                password: _passwordController.text,
                showSuggestions: true,
              ),
            ],

            SizedBox(height: 24),

            // Rol y permisos
            Text(
              'Rol y Permisos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Selector de rol
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Rol',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Administrador'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'store_manager',
                  child: Row(
                    children: [
                      Icon(Icons.store, color: AppColors.accentBlue),
                      SizedBox(width: 8),
                      Text('Encargado de Tienda'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'warehouse_manager',
                  child: Row(
                    children: [
                      Icon(Icons.warehouse, color: AppColors.accentGreen),
                      SizedBox(width: 8),
                      Text('Encargado de Almacén'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'customer',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.accentGrey),
                      SizedBox(width: 8),
                      Text('Cliente'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                  _selectedLocationId = null;
                  _selectedLocationType = null;
                  if (_selectedRole != 'admin') {
                    _assignStoreToAdmin = false;
                  }
                });

                // Cargar ubicaciones si es necesario
                if (value == 'store_manager' || value == 'warehouse_manager') {
                  _loadLocations();
                }
              },
            ),

            // Descripción del rol
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 20, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRoleDescription(),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Asignación de ubicación (solo para managers)
            if (showLocationToggle) ...[
              SizedBox(height: 24),
              SwitchListTile.adaptive(
                value: _assignStoreToAdmin,
                onChanged: (value) {
                  setState(() {
                    _assignStoreToAdmin = value;
                    _selectedLocationId = null;
                    _selectedLocationType = null;
                    if (value) {
                      _loadLocations();
                    }
                  });
                },
                title: const Text('Asignar tienda al administrador'),
                subtitle: const Text(
                    'Opcional. Permite que este usuario administrador gestione una tienda.'),
              ),
            ],

            if (requiresLocation) ...[
              SizedBox(height: 24),
              Text(
                'Asignación de Ubicación',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              if (_selectedRole != 'admin')
                Text(
                  'Los managers deben tener una ubicación asignada',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              if (_selectedRole == 'admin')
                Text(
                  'Selecciona la tienda que administrará este usuario',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              SizedBox(height: 16),

              // Selector de ubicación
              if (_selectedRole == 'store_manager' || (_selectedRole == 'admin' && _assignStoreToAdmin))
                _buildStoreSelector()
              else if (_selectedRole == 'warehouse_manager')
                _buildWarehouseSelector(),
            ],

            SizedBox(height: 32),

            // Botón guardar
            ElevatedButton.icon(
              onPressed: _saveUser,
              icon: Icon(Icons.save),
              label: Text(isEditing ? 'Actualizar Usuario' : 'Crear Usuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelector() {
    if (_isLoadingLocations) {
      return Center(child: CircularProgressIndicator());
    }

    if (_availableLocations.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay tiendas disponibles. Crea una tienda primero.',
            style: TextStyle(color: AppColors.warning),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedLocationId,
      decoration: InputDecoration(
        labelText: 'Tienda Asignada',
        prefixIcon: Icon(Icons.store),
        border: OutlineInputBorder(),
      ),
      hint: Text('Selecciona una tienda'),
      items: _availableLocations.map((location) {
        return DropdownMenuItem<String>(
          value: location['id'] as String,
          child: Text(location['name'] as String),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocationId = value;
          _selectedLocationType = 'store';
        });
      },
      validator: (value) {
        final isRequiredForAdmin = _selectedRole == 'admin' && _assignStoreToAdmin;
        if ((_selectedRole == 'store_manager' || isRequiredForAdmin) && value == null) {
          return 'Debes asignar una tienda';
        }
        return null;
      },
    );
  }

  Widget _buildWarehouseSelector() {
    if (_isLoadingLocations) {
      return Center(child: CircularProgressIndicator());
    }

    if (_availableLocations.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay almacenes disponibles. Crea un almacén primero.',
            style: TextStyle(color: AppColors.warning),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedLocationId,
      decoration: InputDecoration(
        labelText: 'Almacén Asignado',
        prefixIcon: Icon(Icons.warehouse),
        border: OutlineInputBorder(),
      ),
      hint: Text('Selecciona un almacén'),
      items: _availableLocations.map((location) {
        return DropdownMenuItem<String>(
          value: location['id'] as String,
          child: Text(location['name'] as String),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocationId = value;
          _selectedLocationType = 'warehouse';
        });
      },
      validator: (value) {
        if (_selectedRole == 'warehouse_manager' && value == null) {
          return 'Debes asignar un almacén';
        }
        return null;
      },
    );
  }

  String _getRoleDescription() {
    switch (_selectedRole) {
      case 'admin':
        return 'Acceso total al sistema. Puede gestionar usuarios, productos, inventario, órdenes y reportes.';
      case 'store_manager':
        return 'Gestiona una tienda específica. Puede procesar órdenes, ver inventario y generar reportes de su tienda.';
      case 'warehouse_manager':
        return 'Gestiona un almacén específico. Puede gestionar inventario, compras y transferencias.';
      case 'customer':
        return 'Cliente del sistema. Puede navegar productos, hacer compras y ver sus órdenes.';
      default:
        return '';
    }
  }

  void _saveUser() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sanitizedName = InputSanitizer.sanitizeFreeText(_nameController.text.trim());
    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text.trim());

    final rawSafetyWarning = InputSanitizer.firstSafetyWarning([
      _nameController.text,
      _emailController.text,
    ]);
    if (rawSafetyWarning != null) {
      AppLogger.warning('⚠️ Sanitización UserForm: entrada bloqueada -> $rawSafetyWarning');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rawSafetyWarning),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (sanitizedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío o contener caracteres no permitidos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final bloc = widget.userManagementBloc ?? context.read<UserManagementBloc>();
    
    if (isEditing) {
      bloc.add(
            UpdateUser(
              userId: widget.user!.id,
              name: sanitizedName,
              role: _selectedRole,
              assignedLocationId: _selectedLocationId,
              assignedLocationType: _selectedLocationType,
            ),
          );
    } else {
      bloc.add(
            CreateUser(
              email: sanitizedEmail,
              password: _passwordController.text,
              name: sanitizedName,
              role: _selectedRole,
              assignedLocationId: _selectedLocationId,
              assignedLocationType: _selectedLocationType,
            ),
          );
    }

    Navigator.pop(context);
  }
}

