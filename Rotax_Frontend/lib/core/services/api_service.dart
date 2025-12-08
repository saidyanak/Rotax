import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';

/// Web uyumlu dosya sınıfı
class WebFile {
  final String name;
  final Uint8List bytes;
  
  WebFile({required this.name, required this.bytes});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

class ApiService {
  static String? _token;
  
  static void setToken(String? token) {
    _token = token;
  }
  
  static String? get token => _token;
  
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
  
  static Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
      }
      
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }
  
  static Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri, 
        headers: _headers, 
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }
  
  static Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.put(
        uri, 
        headers: _headers, 
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }
  
  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }
  
  static Future<dynamic> multipartPost(String endpoint, {
    required Map<String, String> fields,
    WebFile? file,
    String fileField = 'file',
    List<WebFile>? files,
    String filesField = 'documents',
    String? jsonField,
    Map<String, dynamic>? jsonData,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      // Add regular fields
      request.fields.addAll(fields);
      
      // Add JSON data as a field (for "request" part)
      if (jsonField != null && jsonData != null) {
        request.files.add(http.MultipartFile.fromString(
          jsonField,
          jsonEncode(jsonData),
          contentType: MediaType('application', 'json'),
        ));
      }
      
      // Add single file (web uyumlu - bytes kullan)
      if (file != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          file.bytes,
          filename: file.name,
          contentType: MediaType('image', _getFileExtension(file.name)),
        ));
      }
      
      // Add multiple files (web uyumlu - bytes kullan)
      if (files != null && files.isNotEmpty) {
        for (var f in files) {
          request.files.add(http.MultipartFile.fromBytes(
            filesField,
            f.bytes,
            filename: f.name,
            contentType: MediaType('image', _getFileExtension(f.name)),
          ));
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Bağlantı hatası: $e');
    }
  }
  
  static String _getFileExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'pdf':
        return 'pdf';
      default:
        return 'octet-stream';
    }
  }
  
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Oturum süreniz doldu. Lütfen tekrar giriş yapın.', statusCode: 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Bu işlem için yetkiniz yok.', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException('İstenen kaynak bulunamadı.', statusCode: 404);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw ApiException(error['message'] ?? 'Bir hata oluştu.', statusCode: response.statusCode);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Sunucu hatası: ${response.statusCode}', statusCode: response.statusCode);
      }
    }
  }
}
