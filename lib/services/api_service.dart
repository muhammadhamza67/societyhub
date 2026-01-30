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
      final rawData = List<dynamic>.from(jsonDecode(response.body));
      final normalized = rawData.map((req) {
        final status = req['status'] ?? 'Pending';
        return {
          "title": req['title'] ?? '',
          "category": req['category'] ?? '-',
          "priority": req['priority'] ?? '-',
          "status": normalizeStatus(status),
          "worker_id": req['worker_id'],
          "_id": req['_id'],
        };
      }).toList();

      return normalized;
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getAllRequests() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/requests"));
    if (response.statusCode == 200) {
      final rawData = List<dynamic>.from(jsonDecode(response.body));
      final normalized = rawData.map((req) {
        final status = req['status'] ?? 'Pending';
        return {
          "title": req['title'] ?? '',
          "category": req['category'] ?? '-',
          "priority": req['priority'] ?? '-',
          "status": normalizeStatus(status),
          "worker_id": req['worker_id'],
          "_id": req['_id'],
        };
      }).toList();

      return normalized;
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

  static Future<Map<String, dynamic>?> getResidentProfileById(String residentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/resident/profile/$residentId"),
        headers: {"Content-Type": "application/json"},
      );
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

  static Future<bool> checkResidentProfile(String residentId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/resident/profile/$residentId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getAllResidents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/residents"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= WORKER PROFILE =================
  static Future<bool> saveWorkerProfile({
    required String workerId,
    required String name,
    required String phone,
    required String gully,
    required String houseNo,
    required List<String> skills,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/worker/profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": workerId,
        "name": name,
        "phone": phone,
        "gully": gully,
        "house_no": houseNo,
        "skills": skills,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> getWorkerProfileById(String workerId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/worker/profile/$workerId"));
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

  static Future<bool> checkWorkerProfile(String workerId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/worker/check/$workerId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ================= ADMIN → WORKER APPROVAL =================
  static Future<List<dynamic>> getAllWorkers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/workers"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> approveWorker(String workerId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/approve-worker/$workerId"),
    );
    return response.statusCode == 200;
  }

  static Future<bool> rejectWorker(String workerId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/reject-worker/$workerId"),
    );
    return response.statusCode == 200;
  }

  // ================= CHAT =================
  // Get messages for resident by request
  static Future<List<Map<String, dynamic>>> getResidentChat(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chat/resident/$requestId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Send message as resident
  static Future<bool> sendResidentChat({
    required String requestId,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "request_id": requestId,
          "sender_id": senderId,
          "sender_role": senderRole,
          "message": message,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get messages for admin by request
  static Future<List<Map<String, dynamic>>> getAdminChat(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chat/admin/$requestId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Send message as admin
  static Future<bool> sendAdminChat({
    required String requestId,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "request_id": requestId,
          "sender_id": senderId,
          "sender_role": senderRole,
          "message": message,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get list of resident IDs that have chats (for admin chat list screen)
  static Future<List<String>> getAdminChats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chat/admin/list"), // Backend endpoint must exist
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return List<String>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= HELPER =================
  static String normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'in progress':
        return 'In Progress';
      case 'completed':
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Pending';
    }
  }
}
