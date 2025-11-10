import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Página para recuperación de contraseña
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            setState(() => _isEmailSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email de recuperación enviado'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBeige,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isEmailSent ? _buildEmailSentView() : _buildFormView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Icono
          Icon(
            Icons.lock_reset,
            size: 80,
            color: AppColors.primaryOrange,
          ),

          const SizedBox(height: 32),

          // Título
          Text(
            '¿Olvidaste tu contraseña?',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Campo de email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Ingresa tu email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Por favor ingresa un email válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Botón de envío
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Enviar Email de Recuperación',
                onPressed: state is AuthLoading ? null : _sendResetEmail,
                isLoading: state is AuthLoading,
                backgroundColor: AppColors.primaryBrown,
              );
            },
          ),

          const SizedBox(height: 24),

          // Enlace para volver al login
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Volver al Login',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryOrange,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        // Icono de éxito
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: AppColors.success,
        ),

        const SizedBox(height: 32),

        // Título
        Text(
          '¡Email Enviado!',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Descripción
        Text(
          'Hemos enviado un enlace de recuperación a ${_emailController.text}.\n\nRevisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Botón para reenviar
        CustomButton(
          text: 'Reenviar Email',
          onPressed: _sendResetEmail,
          backgroundColor: AppColors.primaryBrown,
        ),

        const SizedBox(height: 16),

        // Botón para volver al login
        CustomButton(
          text: 'Volver al Login',
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppColors.surfaceBeige,
          textColor: AppColors.primaryBrown,
          borderColor: AppColors.primaryBrown,
        ),
      ],
    );
  }

  void _sendResetEmail() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text);
    if (sanitizedEmail != _emailController.text) {
      _emailController
        ..text = sanitizedEmail
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: sanitizedEmail.length),
        );
    }

    final safetyWarning = InputSanitizer.firstSafetyWarning([sanitizedEmail]);
    if (sanitizedEmail.isEmpty || safetyWarning != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(safetyWarning ?? 'Ingresa un email válido.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthResetPasswordRequested(email: sanitizedEmail),
    );
  }
}