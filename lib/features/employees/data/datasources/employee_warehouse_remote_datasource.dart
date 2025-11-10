import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_warehouse_model.dart';

/// Datasource remoto para empleados de almacén (Supabase)
class EmployeeWarehouseRemoteDatasource {
  final SupabaseClient _supabase;

  EmployeeWarehouseRemoteDatasource(this._supabase);

  /// Obtiene todos los empleados activos
  Stream<List<EmployeeWarehouseModel>> getAll() {
    return _supabase
        .from('employees_warehouse')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('name')
        .map((data) => data.map((json) => EmployeeWarehouseModel.fromJson(json)).toList());
  }

  /// Obtiene todos los empleados (activos e inactivos)
  Stream<List<EmployeeWarehouseModel>> getAllIncludingInactive() {
    return _supabase
        .from('employees_warehouse')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => EmployeeWarehouseModel.fromJson(json)).toList());
  }

  /// Busca empleados por nombre o email
  Future<List<EmployeeWarehouseModel>> search(String query) async {
    final response = await _supabase
        .from('employees_warehouse')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .order('name');

    return (response as List).map((json) => EmployeeWarehouseModel.fromJson(json)).toList();
  }

  /// Obtiene un empleado por email
  Future<EmployeeWarehouseModel?> getByEmail(String email) async {
    final response = await _supabase
        .from('employees_warehouse')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeWarehouseModel.fromJson(response);
  }

  /// Crea un nuevo empleado
  Future<EmployeeWarehouseModel> create({
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
        .from('employees_warehouse')
        .insert(data)
        .select()
        .single();

    return EmployeeWarehouseModel.fromJson(response);
  }

  /// Actualiza un empleado
  Future<EmployeeWarehouseModel> update({
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
        .from('employees_warehouse')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return EmployeeWarehouseModel.fromJson(response);
  }

  /// Desactiva un empleado
  Future<void> deactivate(String employeeId) async {
    await _supabase
        .from('employees_warehouse')
        .update({'is_active': false})
        .eq('id', employeeId);
  }

  /// Activa un empleado
  Future<void> activate(String employeeId) async {
    await _supabase
        .from('employees_warehouse')
        .update({'is_active': true})
        .eq('id', employeeId);
  }
  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId}) async {
    var query = _supabase
        .from('employees_warehouse')
        .select('id')
        .eq('ci', ci);

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final response = await query.maybeSingle();
    return response != null;
  }

}
