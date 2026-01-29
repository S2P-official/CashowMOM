import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.29.215:8080/api";


  // ---------------------------------------------------
  // LOGIN REQUEST
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> login(String identifier, String password) async {
    try {
      final url = Uri.parse("$baseUrl/employees/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        
        return null;
      }
    } catch (e) {
     
      return null;
    }
  }

  // ---------------------------------------------------
  // TOKEN VALIDATION
  // ---------------------------------------------------
 Future<Map<String, dynamic>?> validateToken(String token) async {
  try {
    final url = Uri.parse("$baseUrl/employees/validate");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["valid"] == true) {
        return data;
      }
    }

    return null; // invalid token or non-200 response
  } catch (e) {
    
    return null;
  }
}

}
