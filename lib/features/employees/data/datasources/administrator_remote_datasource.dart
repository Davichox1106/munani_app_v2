import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/administrator_model.dart';

/// Datasource remoto para administradores (Supabase)
class AdministratorRemoteDatasource {
  final SupabaseClient _supabase;

  AdministratorRemoteDatasource(this._supabase);

  /// Obtiene todos los administradores activos
  Stream<List<AdministratorModel>> getAll() {
    return _supabase
        .from('administrators')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('name')
        .map((data) => data.map((json) => AdministratorModel.fromJson(json)).toList());
  }

  /// Obtiene todos los administradores (activos e inactivos)
  Stream<List<AdministratorModel>> getAllIncludingInactive() {
    return _supabase
        .from('administrators')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => AdministratorModel.fromJson(json)).toList());
  }

  /// Busca administradores por nombre o email
  Future<List<AdministratorModel>> search(String query) async {
    final response = await _supabase
        .from('administrators')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .order('name');

    return (response as List).map((json) => AdministratorModel.fromJson(json)).toList();
  }

  /// Obtiene un administrador por email
  Future<AdministratorModel?> getByEmail(String email) async {
    final response = await _supabase
        .from('administrators')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return AdministratorModel.fromJson(response);
  }

  /// Crea un nuevo administrador
  Future<AdministratorModel> create({
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? notes,
    required String createdBy,
  }) async {
    final data = {
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'ci': ci,
      'address': address,
      'notes': notes,
      'is_active': true,
      'created_by': createdBy,
      'updated_by': createdBy,
    };

    final response = await _supabase
        .from('administrators')
        .insert(data)
        .select()
        .single();

    return AdministratorModel.fromJson(response);
  }

  /// Actualiza un administrador
  Future<AdministratorModel> update({
    required String id,
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? notes,
    required String updatedBy,
  }) async {
    final data = {
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'ci': ci,
      'address': address,
      'notes': notes,
      'updated_by': updatedBy,
    };

    final response = await _supabase
        .from('administrators')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return AdministratorModel.fromJson(response);
  }

  /// Desactiva un administrador
  Future<void> deactivate(String administratorId) async {
    await _supabase
        .from('administrators')
        .update({'is_active': false})
        .eq('id', administratorId);
  }

  /// Activa un administrador
  Future<void> activate(String administratorId) async {
    await _supabase
        .from('administrators')
        .update({'is_active': true})
        .eq('id', administratorId);
  }

  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId}) async {
    var query = _supabase
        .from('administrators')
        .select('id')
        .eq('ci', ci);

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final response = await query.maybeSingle();
    return response != null;
  }
}
