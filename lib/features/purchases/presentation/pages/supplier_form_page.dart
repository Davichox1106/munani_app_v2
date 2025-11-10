import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart' as supplier_event;
import '../bloc/supplier_state.dart';

/// Página de formulario para crear o editar proveedores
class SupplierFormPage extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormPage({
    super.key,
    this.supplier,
  });

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _rucNitController;
  late final TextEditingController _notesController;
  late bool _isActive;

  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactNameController = TextEditingController(text: widget.supplier?.contactName ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _rucNitController = TextEditingController(text: widget.supplier?.rucNit ?? '');
    _notesController = TextEditingController(text: widget.supplier?.notes ?? '');
    _isActive = widget.supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _rucNitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveSupplier() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Obtener el usuario actual del contexto de autenticación
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario no autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = authState.user.id;

    if (_isEditing) {
      final updatedSupplier = widget.supplier!.copyWith(
        name: _nameController.text.trim(),
        contactName: _contactNameController.text.trim().isEmpty
            ? null
            : _contactNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        rucNit: _rucNitController.text.trim().isEmpty
            ? null
            : _rucNitController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isActive: _isActive,
      );

      context.read<SupplierBloc>().add(
        supplier_event.UpdateSupplier(
          supplier: updatedSupplier,
          updatedBy: userId,
        ),
      );
    } else {
      context.read<SupplierBloc>().add(
        supplier_event.CreateSupplier(
          name: _nameController.text.trim(),
          contactName: _contactNameController.text.trim().isEmpty
              ? null
              : _contactNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          rucNit: _rucNitController.text.trim().isEmpty
              ? null
              : _rucNitController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdBy: userId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor'),
      ),
      body: BlocConsumer<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final isLoading = state is SupplierSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre (requerido)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Proveedor *',
                      hintText: 'Ej: Distribuidora NutriSnack',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // RUC/NIT
                  TextFormField(
                    controller: _rucNitController,
                    decoration: const InputDecoration(
                      labelText: 'RUC/NIT',
                      hintText: 'Ej: 1234567890001',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Nombre de contacto
                  TextFormField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Contacto',
                      hintText: 'Ej: Juan Pérez',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      hintText: 'Ej: 0991234567',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Ej: contacto@proveedor.com',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Email inválido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dirección
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'Ej: Av. Principal y Calle 1',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      hintText: 'Información adicional...',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Estado activo/inactivo (solo en edición)
                  if (_isEditing)
                    Card(
                      child: SwitchListTile(
                        title: const Text('Estado'),
                        subtitle: Text(_isActive ? 'Activo' : 'Inactivo'),
                        value: _isActive,
                        onChanged: isLoading ? null : (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        secondary: Icon(
                          _isActive ? Icons.check_circle : Icons.cancel,
                          color: _isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Botón de guardar
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _saveSupplier,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading
                          ? 'Guardando...'
                          : (_isEditing ? 'Actualizar' : 'Crear Proveedor'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nota informativa
                  const Text(
                    '* Campos requeridos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
