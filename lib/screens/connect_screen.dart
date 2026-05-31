import 'package:flutter/material.dart';
import '../theme.dart';
import '../api.dart';
import 'home_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _url = TextEditingController(text: 'http://');
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ApiService.instance
        .pair(_url.text, _user.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flutter_dash, color: Hawks.gold, size: 64),
                const SizedBox(height: 8),
                hawksWordmark(size: 34),
                const SizedBox(height: 4),
                const Text('Shop · Staff App',
                    style: TextStyle(color: Hawks.textMuted, fontSize: 15)),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Pair with the shop PC',
                      style: TextStyle(
                          color: Hawks.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Open Admin → Mobile on the desktop app for the address.',
                      style: TextStyle(color: Hawks.textDim, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                      labelText: 'Shop address',
                      hintText: 'http://192.168.1.10:9810'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _user,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: Hawks.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _connect,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Text('CONNECT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
