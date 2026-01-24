import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  // ================= REQUESTS =================
  static Future<bool> submitRequest({
    required String title,
    required String description,
    required String residentId,
    required String category,
    required String priority,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resident/request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "description": description,
        "resident_id": residentId,
        "category": category,
        "priority": priority,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getRequestsForResident(String residentId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/resident/requests/$residentId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getAllRequests() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/requests"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> assignTask(String requestId, String workerId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/assign-task"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "request_id": requestId,
        "worker_id": workerId,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getWorkerTasks(String workerId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/worker/tasks/$workerId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> updateTaskStatus(String taskId, String status) async {
    final response = await http.put(
      Uri.parse("$baseUrl/worker/update-status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "task_id": taskId,
        "status": status,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/tasks"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  // ================= RESIDENT PROFILE =================
  static Future<bool> saveResidentProfile({
    required String residentId,
    required String name,
    required String phone,
    required String gully,
    required String houseNo,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resident/profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "resident_id": residentId,
        "name": name,
        "phone": phone,
        "gully": gully,
        "house_no": houseNo,
      }),
    );
    return response.statusCode == 200;
  }

  // ================= GET RESIDENT PROFILE BY ID =================
  static Future<Map<String, dynamic>?> getResidentProfileById(String residentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/resident/profile/$residentId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          return data['data']; // returns full resident profile
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ================= CHECK RESIDENT PROFILE BY ID =================
  static Future<bool> checkResidentProfile(String residentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/resident/profile/$residentId"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ================= CHECK RESIDENT PROFILE BY EMAIL =================
  static Future<Map<String, dynamic>?> getResidentByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/resident/profile_by_email/$email"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ================= ADMIN: GET ALL RESIDENTS =================
  static Future<List<dynamic>> getAllResidents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/residents"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
