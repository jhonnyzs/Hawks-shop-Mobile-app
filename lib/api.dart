import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Talks to the desktop Hawks Shop "mobile bridge" over the shop Wi-Fi.
class ApiService {
  String baseUrl = '';
  String token = '';
  String shopName = 'Hawkstronix';
  String currency = 'E£';

  static final ApiService instance = ApiService._();
  ApiService._();

  bool get isPaired => baseUrl.isNotEmpty && token.isNotEmpty;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = p.getString('baseUrl') ?? '';
    token = p.getString('token') ?? '';
    shopName = p.getString('shop') ?? 'Hawkstronix';
    currency = p.getString('currency') ?? 'E£';
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('baseUrl', baseUrl);
    await p.setString('token', token);
    await p.setString('shop', shopName);
    await p.setString('currency', currency);
  }

  Future<void> clear() async {
    baseUrl = '';
    token = '';
    final p = await SharedPreferences.getInstance();
    await p.remove('baseUrl');
    await p.remove('token');
  }

  Map<String, String> get _headers =>
      {'Content-Type': 'application/json', 'X-Hawks-Token': token};

  String money(num v) => '$currency${v.toStringAsFixed(0)}';

  Uri _u(String base, String path) => Uri.parse('$base$path');

  /// Check a server is a Hawks Shop bridge before pairing.
  Future<Map<String, dynamic>> ping(String url) async {
    final r = await http
        .get(_u(url, '/api/ping'))
        .timeout(const Duration(seconds: 6));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// Pair using shop username + password → stores baseUrl + token.
  Future<String?> pair(String url, String user, String pass) async {
    url = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (!url.startsWith('http')) url = 'http://$url';
    try {
      final r = await http
          .post(_u(url, '/api/pair'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'username': user, 'password': pass}))
          .timeout(const Duration(seconds: 8));
      final b = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode == 200 && b['token'] != null) {
        baseUrl = url;
        token = b['token'];
        shopName = b['shop'] ?? 'Hawkstronix';
        await _save();
        // pull the currency from a summary call
        try {
          final s = await summary();
          if (s['currency'] != null) {
            currency = s['currency'];
            await _save();
          }
        } catch (_) {}
        return null; // success
      }
      return b['error'] ?? 'Could not pair (${r.statusCode}).';
    } catch (e) {
      return 'Cannot reach the shop PC. Check the address and Wi-Fi.';
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final r = await http
        .get(_u(baseUrl, path), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) {
      throw Exception('Error ${r.statusCode}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, Map body) async {
    final r = await http
        .post(_u(baseUrl, path), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) {
      final b = jsonDecode(r.body);
      throw Exception(b['error'] ?? 'Error ${r.statusCode}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> summary() => _get('/api/summary');

  Future<List<dynamic>> inventory(String q) async =>
      (await _get('/api/inventory?q=${Uri.encodeComponent(q)}'))['items'] ?? [];

  Future<num> adjustStock(int id, num delta, String reason) async {
    final b =
        await _post('/api/inventory/adjust', {'id': id, 'delta': delta, 'reason': reason});
    return b['qty'] ?? 0;
  }

  Future<List<dynamic>> orders([String status = '']) async =>
      (await _get('/api/orders?status=${Uri.encodeComponent(status)}'))['orders'] ?? [];

  Future<void> setOrderStatus(int id, String status) =>
      _post('/api/order/status', {'id': id, 'status': status});

  Future<List<dynamic>> jobs([String status = '']) async =>
      (await _get('/api/jobs?status=${Uri.encodeComponent(status)}'))['jobs'] ?? [];

  Future<void> setJobStatus(int id, String status) =>
      _post('/api/job/status', {'id': id, 'status': status});
}
