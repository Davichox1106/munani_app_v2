import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../users/domain/entities/user.dart' as user_management;
import '../../../users/domain/usecases/create_user.dart';

class CustomerSignupPage extends StatefulWidget {
  const CustomerSignupPage({super.key});

  @override
  State<CustomerSignupPage> createState() => _CustomerSignupPageState();
}

class _CustomerSignupPageState extends State<CustomerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ciController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  CreateUser get _createUserUseCase => GetIt.I<CreateUser>();
  CustomerRepository get _customerRepository => GetIt.I<CustomerRepository>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ciController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final rawName = _nameController.text;
    final rawAddress = _addressController.text;
    final rawEmail = _emailController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final rawSafetyWarning = InputSanitizer.firstSafetyWarning([
      rawName,
      rawAddress,
      rawEmail,
    ]);

    if (rawSafetyWarning != null) {
      AppLogger.warning('⚠️ Sanitización Signup: entrada bloqueada -> $rawSafetyWarning');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rawSafetyWarning),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final sanitizedName = InputSanitizer.sanitizeFreeText(_nameController.text);
    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text);
    final sanitizedCi = InputSanitizer.sanitizeAlphanumeric(_ciController.text, allowSpaces: false);
    final sanitizedPhoneRaw = InputSanitizer.sanitizePhone(_phoneController.text);
    final sanitizedAddress = InputSanitizer.sanitizeAddress(_addressController.text);

    if (sanitizedName.isEmpty || sanitizedCi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los campos de nombre y documento no pueden estar vacíos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (sanitizedCi.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El documento debe tener al menos 5 caracteres válidos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final sanitizedPhone = sanitizedPhoneRaw.isEmpty ? null : sanitizedPhoneRaw;
    final sanitizedAddressOrNull = sanitizedAddress.isEmpty ? null : sanitizedAddress;

    setState(() => _isLoading = true);

    final result = await _createUserUseCase(
      email: sanitizedEmail,
      password: password,
      name: sanitizedName,
      role: 'customer',
      assignedLocationId: null,
      assignedLocationType: null,
    );

    await result.fold(
      (failure) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) async {
        var customerCreated = true;
        try {
          await _createCustomerProfile(
            user: user,
            email: sanitizedEmail,
            name: sanitizedName,
            ci: sanitizedCi,
            phone: sanitizedPhone,
            address: sanitizedAddressOrNull,
            plainPassword: password,
          );
        } catch (e) {
          customerCreated = false;
          AppLogger.error('❌ Error al crear cliente asociado: $e');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customerCreated
                  ? 'Cuenta creada correctamente. Ahora puedes iniciar sesión.'
                  : 'Cuenta creada. Completa tus datos de cliente más adelante.',
            ),
            backgroundColor: customerCreated ? AppColors.success : AppColors.warning,
          ),
        );
        Navigator.of(context).pop<String>(sanitizedEmail);
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createCustomerProfile({
    required user_management.User user,
    required String email,
    required String name,
    required String ci,
    required String? phone,
    required String? address,
    required String plainPassword,
  }) async {
    final supabase = Supabase.instance.client;
    final previousSession = supabase.auth.currentSession;
    bool signedInTemporarily = false;

    try {
      if (previousSession?.user.id != user.id) {
        final signInResponse = await supabase.auth.signInWithPassword(
          email: user.email,
          password: plainPassword,
        );

        if (signInResponse.session == null) {
          throw Exception('No se pudo iniciar sesión para registrar el perfil de cliente.');
        }
        signedInTemporarily = true;
      }

      final now = DateTime.now();
      final customer = Customer(
        id: user.id,
        ci: ci,
        name: name,
        phone: phone,
        email: email,
        address: address,
        assignedLocationId: user.assignedLocationId,
        assignedLocationType: user.assignedLocationType,
        assignedLocationName: null,
        createdBy: user.id,
        createdAt: now,
        updatedAt: now,
      );

      await _customerRepository.create(customer);
    } finally {
      if (signedInTemporarily) {
        await supabase.auth.signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceBeige,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Regístrate como cliente',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa tus datos para crear una cuenta de cliente y acceder a Munani.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'cliente@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ciController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Documento de identidad',
                    hintText: 'Ej: 12345678 LP',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu documento de identidad';
                    }
                    if (value.trim().length < 5) {
                      return 'El documento debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ej: +591 70000000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu número de teléfono';
                    }
                    if (value.trim().length < 6) {
                      return 'El teléfono debe tener al menos 6 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    hintText: 'Ej: Av. Principal #123, Zona Centro',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu dirección';
                    }
                    if (value.trim().length < 5) {
                      return 'La dirección debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}), // Actualizar indicador de fortaleza
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    // Validar con PasswordValidator
                    final result = PasswordValidator.validate(value);
                    if (!result.isValid) {
                      return result.errors.first;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Indicador de fortaleza de contraseña
                PasswordStrengthIndicator(
                  password: _passwordController.text,
                  showSuggestions: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _onSubmit(),
                ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




