import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../locations/domain/repositories/location_repository.dart';
import '../../../locations/domain/entities/store.dart';
import '../../../locations/domain/entities/warehouse.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? existing;
  const CustomerFormPage({super.key, this.existing});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ci;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  String? _selectedLocationType;
  String? _selectedLocationId;
  String? _selectedLocationName;
  bool _isLoadingLocations = false;
  List<Map<String, String>> _availableLocations = [];
  bool _saving = false;

  CustomerRepository get _repo => GetIt.I<CustomerRepository>();
  LocationRepository get _locationRepo => GetIt.I<LocationRepository>();

  @override
  void initState() {
    super.initState();
    _ci = TextEditingController(text: widget.existing?.ci ?? '');
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _phone = TextEditingController(text: widget.existing?.phone ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
    _address = TextEditingController(text: widget.existing?.address ?? '');
    _selectedLocationType = widget.existing?.assignedLocationType;
    _selectedLocationId = widget.existing?.assignedLocationId;
    _selectedLocationName = widget.existing?.assignedLocationName;

    if (_selectedLocationType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLocations(_selectedLocationType!);
      });
    }
  }

  @override
  void dispose() {
    _ci.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _loadLocations(String type) async {
    setState(() {
      _isLoadingLocations = true;
      _availableLocations = [];
    });

    final result = type == 'store'
        ? await _locationRepo.getAllStores()
        : await _locationRepo.getAllWarehouses();

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar ${type == 'store' ? 'tiendas' : 'almacenes'}: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoadingLocations = false;
          _availableLocations = [];
          _selectedLocationId = null;
          _selectedLocationName = null;
        });
      },
      (locations) {
        final mappedLocations = locations.map<Map<String, String>>((location) {
          if (location is Store) {
            return {'id': location.id, 'name': location.name};
          }
          if (location is Warehouse) {
            return {'id': location.id, 'name': location.name};
          }
          return {'id': '', 'name': ''};
        }).where((loc) => (loc['id'] ?? '').isNotEmpty).toList();

        setState(() {
          _availableLocations = mappedLocations;
          final index = _availableLocations.indexWhere(
            (loc) => loc['id'] == _selectedLocationId,
          );
          if (index == -1) {
            _selectedLocationId = null;
            _selectedLocationName = null;
          } else {
            _selectedLocationName = _availableLocations[index]['name'];
          }
          _isLoadingLocations = false;
        });
      },
    );
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

    if (_selectedLocationType != null && _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecciona una ${_selectedLocationType == 'store' ? 'tienda' : 'almacén'} para asignar.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final currentUserId = authState.user.id;
      final locationId = _selectedLocationType == null ? null : _selectedLocationId;
      final locationName = _selectedLocationType == null ? null : _selectedLocationName;
      final customer = Customer(
        id: widget.existing?.id ?? '',
        ci: _ci.text.trim(),
        name: _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        assignedLocationId: locationId,
        assignedLocationType: _selectedLocationType,
        assignedLocationName: locationName,
        createdBy: widget.existing?.createdBy ?? currentUserId,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      if (widget.existing == null) {
        await _repo.create(customer);
      } else {
        await _repo.update(customer);
      }

      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
      }
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
      appBar: AppBar(
        title: Text(isEdit ? 'Editar cliente' : 'Nuevo cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _ci,
                decoration: const InputDecoration(
                  labelText: 'CI *',
                  hintText: 'Ej: 12345678',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'El CI es requerido' : null,
                enabled: !_saving,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej: 0991234567',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                enabled: !_saving,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ej: cliente@correo.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                enabled: !_saving,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Email inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ej: Av. Principal y Calle 1',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                enabled: !_saving,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              Text(
                'Ubicación asignada (opcional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                key: ValueKey('type-${_selectedLocationType ?? 'none'}'),
                initialValue: _selectedLocationType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de ubicación',
                  prefixIcon: Icon(Icons.place),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Sin ubicación asignada'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'store',
                    child: Text('Tienda'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'warehouse',
                    child: Text('Almacén'),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedLocationType = value;
                          _selectedLocationId = null;
                          _selectedLocationName = null;
                          _availableLocations = [];
                        });
                        if (value != null) {
                          _loadLocations(value);
                        }
                      },
              ),
              if (_selectedLocationType != null) ...[
                const SizedBox(height: 12),
                if (_isLoadingLocations)
                  const Center(child: CircularProgressIndicator())
                else if (_availableLocations.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _selectedLocationType == 'store'
                            ? 'No hay tiendas disponibles. Crea una tienda primero.'
                            : 'No hay almacenes disponibles. Crea un almacén primero.',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    key: ValueKey('location-${_selectedLocationType ?? 'none'}-${_selectedLocationId ?? 'none'}'),
                    initialValue: _selectedLocationId,
                    decoration: InputDecoration(
                      labelText: _selectedLocationType == 'store' ? 'Tienda' : 'Almacén',
                      prefixIcon: Icon(
                        _selectedLocationType == 'store' ? Icons.store : Icons.warehouse,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: _availableLocations
                        .map(
                          (loc) => DropdownMenuItem<String?>(
                            value: loc['id'],
                            child: Text(loc['name'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedLocationId = value;
                              _selectedLocationName = _availableLocations
                                  .firstWhere(
                                    (loc) => loc['id'] == value,
                                    orElse: () => {'id': '', 'name': ''},
                                  )['name'];
                            });
                          },
                    hint: Text('Selecciona ${_selectedLocationType == 'store' ? 'una tienda' : 'un almacén'}'),
                  ),
                const SizedBox(height: 16),
              ],

              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : (isEdit ? 'Actualizar' : 'Crear Cliente')),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),

              const SizedBox(height: 16),
              const Text(
                '* Campos requeridos',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

