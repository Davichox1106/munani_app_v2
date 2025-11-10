import 'package:flutter/material.dart';
import '../../domain/entities/employee_store.dart';
import '../../domain/repositories/employee_store_repository.dart';
import '../../../../core/di/injection_container.dart';
import 'employees_store_form_page.dart';

/// Página para gestionar empleados de tienda
class EmployeesStorePage extends StatefulWidget {
  const EmployeesStorePage({super.key});

  @override
  State<EmployeesStorePage> createState() => _EmployeesStorePageState();
}

class _EmployeesStorePageState extends State<EmployeesStorePage> {
  final _repository = sl<EmployeeStoreRepository>();
  final _searchController = TextEditingController();
  List<EmployeeStore>? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    final results = await _repository.search(query);
    setState(() => _searchResults = results);
  }

  Future<void> _showForm([EmployeeStore? employee]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeesStoreFormPage(existing: employee),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _searchResults = null;
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados de Tienda'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<EmployeeStore>>(
        stream: _repository.getAllIncludingInactive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final employees = _searchResults ?? snapshot.data ?? [];

          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchResults != null
                        ? 'No se encontraron resultados'
                        : 'No hay empleados de tienda registrados',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: employee.isActive ? Colors.green : Colors.grey,
                    child: Text(
                      employee.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.email),
                      if (employee.position != null) Text('Cargo: ${employee.position}'),
                      if (employee.department != null) Text('Depto: ${employee.department}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(employee.isActive ? 'Activo' : 'Inactivo'),
                        backgroundColor: employee.isActive ? Colors.green[100] : Colors.grey[300],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(employee),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Empleado'),
      ),
    );
  }
}

