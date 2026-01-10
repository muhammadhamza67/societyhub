import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";
 
  static Future<bool> submitRequest({
    required String title,
    required String description,
    required String residentId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resident/request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "description": description,
        "resident_id": residentId,
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
}
