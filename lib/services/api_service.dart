import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/company.dart';
import '../models/service.dart';
import 'api_exception.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 10);
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // GET /companies
  Future<List<Company>> getCompanies() async {
    final data = await _send(() => _client.get(_uri('/companies')));
    return (data as List<dynamic>)
        .map((c) => Company.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  // POST /companies
  Future<Company> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final data = await _send(() => _client.post(
      _uri('/companies'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'registrationNumber': registrationNumber,
      }),
    ));
    return Company.fromJson(data as Map<String, dynamic>);
  }

  // POST /services
  Future<Service> createService({
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final data = await _send(() => _client.post(
      _uri('/services'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': description,
        'price': price,
      }),
    ));
    return Service.fromJson(data as Map<String, dynamic>);
  }

  // Sends the request and turns every kind of failure into an ApiException
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response res;
    try {
      res = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    } catch (_) {
      throw ApiException('Cannot connect to the server. Is the backend running?');
    }

    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } on FormatException {
      body = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    throw ApiException(
      _errorMessage(body, res.statusCode),
      statusCode: res.statusCode,
    );
  }

  // Uses the backend's own error messages (validation errors or "message")
  String _errorMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e['message']).join('\n');
      }
      if (body['message'] is String) return body['message'] as String;
    }
    return 'Request failed ($statusCode)';
  }
}