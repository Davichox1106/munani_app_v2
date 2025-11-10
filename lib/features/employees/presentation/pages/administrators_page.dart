import 'package:flutter/material.dart';
import '../../domain/entities/administrator.dart';
import '../../domain/repositories/administrator_repository.dart';
import '../../../../core/di/injection_container.dart';
import 'administrators_form_page.dart';

/// Página para gestionar administradores
class AdministratorsPage extends StatefulWidget {
  const AdministratorsPage({super.key});

  @override
  State<AdministratorsPage> createState() => _AdministratorsPageState();
}

class _AdministratorsPageState extends State<AdministratorsPage> {
  final _repository = sl<AdministratorRepository>();
  final _searchController = TextEditingController();
  List<Administrator>? _searchResults;

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

  Future<void> _showForm([Administrator? administrator]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdministratorsFormPage(existing: administrator),
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
        title: const Text('Administradores'),
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
      body: StreamBuilder<List<Administrator>>(
        stream: _repository.getAllIncludingInactive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final administrators = _searchResults ?? snapshot.data ?? [];

          if (administrators.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchResults != null
                        ? 'No se encontraron resultados'
                        : 'No hay administradores registrados',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: administrators.length,
            itemBuilder: (context, index) {
              final admin = administrators[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: admin.isActive ? Colors.blue : Colors.grey,
                    child: Text(
                      admin.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(admin.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(admin.email),
                      if (admin.phone != null) Text('Tel: ${admin.phone}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(admin.isActive ? 'Activo' : 'Inactivo'),
                        backgroundColor: admin.isActive ? Colors.green[100] : Colors.grey[300],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(admin),
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
        label: const Text('Nuevo Admin'),
      ),
    );
  }
}

