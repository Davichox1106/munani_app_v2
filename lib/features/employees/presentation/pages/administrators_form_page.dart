import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/administrator.dart';
import '../../domain/repositories/administrator_repository.dart';

class AdministratorsFormPage extends StatefulWidget {
  final Administrator? existing;
  const AdministratorsFormPage({super.key, this.existing});

  @override
  State<AdministratorsFormPage> createState() => _AdministratorsFormPageState();
}

class _AdministratorsFormPageState extends State<AdministratorsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ciController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _contactNameController.text = widget.existing!.contactName ?? '';
      _phoneController.text = widget.existing!.phone ?? '';
      _emailController.text = widget.existing!.email;
      _ciController.text = widget.existing!.ci ?? '';
      _addressController.text = widget.existing!.address ?? '';
      _notesController.text = widget.existing!.notes ?? '';
      _isActive = widget.existing!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ciController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = sl<AdministratorRepository>();

      final ci = _ciController.text.trim();
      if (ci.isNotEmpty) {
        final exists = await repo.existsCi(ci, excludeId: widget.existing?.id);
        if (exists) {
          throw Exception('Ya existe un administrador con este CI');
        }
      }

      if (widget.existing == null) {
        await repo.create(
          name: _nameController.text.trim(),
          contactName: _contactNameController.text.trim().isEmpty ? null : _contactNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim(),
          ci: _ciController.text.trim().isEmpty ? null : _ciController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdBy: authState.user.id,
        );
      } else {
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          contactName: _contactNameController.text.trim().isEmpty ? null : _contactNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim(),
          ci: _ciController.text.trim().isEmpty ? null : _ciController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await repo.update(updated, authState.user.id);
        if (_isActive != widget.existing!.isActive) {
          if (_isActive) {
            await repo.activate(widget.existing!.id);
          } else {
            await repo.deactivate(widget.existing!.id);
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Administrador' : 'Nuevo Administrador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                textCapitalization: TextCapitalization.words,
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final re = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
                  if (!re.hasMatch(v.trim())) return 'Email inválido';
                  return null;
                },
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ciController,
                decoration: const InputDecoration(
                  labelText: 'CI *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                keyboardType: TextInputType.number,
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Contacto',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_saving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_saving,
              ),
              if (isEdit) ...[
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Estado'),
                    subtitle: Text(_isActive ? 'Activo' : 'Inactivo'),
                    value: _isActive,
                    onChanged: _saving ? null : (v) => setState(() => _isActive = v),
                    secondary: Icon(_isActive ? Icons.check_circle : Icons.cancel, color: _isActive ? Colors.green : Colors.red),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : (isEdit ? 'Actualizar' : 'Crear Admin')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
