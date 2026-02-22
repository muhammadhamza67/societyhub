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
    try {
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
    } catch (e) {
      print("Error submitting request: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getRequestsForResident(String residentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/resident/requests/$residentId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final rawData = List<dynamic>.from(jsonDecode(response.body));
        return rawData.map((req) {
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
      }
      return [];
    } catch (e) {
      print("Error fetching resident requests: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getAllRequests() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/requests"));
      if (response.statusCode == 200) {
        final rawData = List<dynamic>.from(jsonDecode(response.body));
        return rawData.map((req) {
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
      }
      return [];
    } catch (e) {
      print("Error fetching all requests: $e");
      return [];
    }
  }

  // ================= ASSIGN TASK =================
  static Future<bool> assignTask(String requestId, String workerUid) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/assign-task"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "request_id": requestId,
          "worker_id": workerUid,
        }),
      );

      if (response.statusCode != 200) {
        print("Assign task failed: ${response.body}");
      }

      return response.statusCode == 200;
    } catch (e) {
      print("Error assigning task: $e");
      return false;
    }
  }

  // ================= WORKER TASKS =================
  static Future<List<Map<String, dynamic>>> getOpenTasks() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/worker/tasks"));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error fetching open tasks: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTasksForWorker(String workerUid) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/worker/tasks/$workerUid"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((task) => Map<String, dynamic>.from(task)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching tasks for worker $workerUid: $e");
      return [];
    }
  }

  // ✅ Unified function to update task status
  static Future<bool> markTaskComplete({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/worker/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "task_id": taskId,
          "status": status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating task status: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getAllTasks() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/tasks"));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error fetching all tasks: $e");
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
    try {
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
    } catch (e) {
      print("Error saving resident profile: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getResidentProfileById(String residentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/resident/profile/$residentId"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching resident profile: $e");
      return null;
    }
  }

  static Future<bool> checkResidentProfile(String residentId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/resident/profile/$residentId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      print("Error checking resident profile: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getAllResidents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/residents"));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error fetching all residents: $e");
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
    try {
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
    } catch (e) {
      print("Error saving worker profile: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getWorkerProfileById(String workerId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/worker/profile/$workerId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching worker profile: $e");
      return null;
    }
  }

  static Future<bool> checkWorkerProfile(String workerId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/worker/check/$workerId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      print("Error checking worker profile: $e");
      return false;
    }
  }

  // ================= ADMIN → WORKER APPROVAL =================
  static Future<List<dynamic>> getAllWorkers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/workers"));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((w) => {
          "_id": w["_id"] ?? "",
          "name": w["name"] ?? "",
          "firebase_uid": w["firebase_uid"] ?? "",
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching workers: $e");
      return [];
    }
  }

  static Future<bool> approveWorker(String workerId) async {
    try {
      final response = await http.put(Uri.parse("$baseUrl/admin/approve-worker/$workerId"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error approving worker: $e");
      return false;
    }
  }

  static Future<bool> rejectWorker(String workerId) async {
    try {
      final response = await http.put(Uri.parse("$baseUrl/admin/reject-worker/$workerId"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error rejecting worker: $e");
      return false;
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

  // ================= RATING =================
  static Future<bool> submitWorkerRating({
    required String workerId,
    required String residentId,
    required String requestId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/resident/rate-worker"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "worker_id": workerId,
          "resident_id": residentId,
          "request_id": requestId,
          "rating": rating,
          "comment": comment,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error submitting rating: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getWorkerRatings(String workerId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/worker/ratings/$workerId"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print("Error fetching worker ratings: $e");
      return null;
    }
  }
}