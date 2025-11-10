import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_store_model.dart';

/// Datasource remoto para empleados de tienda (Supabase)
class EmployeeStoreRemoteDatasource {
  final SupabaseClient _supabase;

  EmployeeStoreRemoteDatasource(this._supabase);

  /// Obtiene todos los empleados activos
  Stream<List<EmployeeStoreModel>> getAll() {
    return _supabase
        .from('employees_store')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('name')
        .map((data) => data.map((json) => EmployeeStoreModel.fromJson(json)).toList());
  }

  /// Obtiene todos los empleados (activos e inactivos)
  Stream<List<EmployeeStoreModel>> getAllIncludingInactive() {
    return _supabase
        .from('employees_store')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => EmployeeStoreModel.fromJson(json)).toList());
  }

  /// Busca empleados por nombre o email
  Future<List<EmployeeStoreModel>> search(String query) async {
    final response = await _supabase
        .from('employees_store')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .order('name');

    return (response as List).map((json) => EmployeeStoreModel.fromJson(json)).toList();
  }

  /// Obtiene un empleado por email
  Future<EmployeeStoreModel?> getByEmail(String email) async {
    final response = await _supabase
        .from('employees_store')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeStoreModel.fromJson(response);
  }

  /// Crea un nuevo empleado
  Future<EmployeeStoreModel> create({
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? position,
    String? department,
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
      'position': position,
      'department': department,
      'notes': notes,
      'is_active': true,
      'created_by': createdBy,
      'updated_by': createdBy,
    };

    final response = await _supabase
        .from('employees_store')
        .insert(data)
        .select()
        .single();

    return EmployeeStoreModel.fromJson(response);
  }

  /// Actualiza un empleado
  Future<EmployeeStoreModel> update({
    required String id,
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? position,
    String? department,
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
      'position': position,
      'department': department,
      'notes': notes,
      'updated_by': updatedBy,
    };

    final response = await _supabase
        .from('employees_store')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return EmployeeStoreModel.fromJson(response);
  }

  /// Desactiva un empleado
  Future<void> deactivate(String employeeId) async {
    await _supabase
        .from('employees_store')
        .update({'is_active': false})
        .eq('id', employeeId);
  }

  /// Activa un empleado
  Future<void> activate(String employeeId) async {
    await _supabase
        .from('employees_store')
        .update({'is_active': true})
        .eq('id', employeeId);
  }

  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId}) async {
    var query = _supabase
        .from('employees_store')
        .select('id')
        .eq('ci', ci);

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final response = await query.maybeSingle();
    return response != null;
  }
}
