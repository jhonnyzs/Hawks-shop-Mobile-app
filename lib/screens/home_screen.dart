import 'package:flutter/material.dart';
import '../theme.dart';
import '../api.dart';
import 'connect_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import 'jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.summary();
  }

  void _reload() => setState(() => _future = ApiService.instance.summary());

  Future<void> _disconnect() async {
    await ApiService.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConnectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiService.instance;
    return Scaffold(
      appBar: AppBar(
        title: hawksWordmark(),
        actions: [
          IconButton(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, color: Hawks.gold)),
          IconButton(
              onPressed: _disconnect,
              icon: const Icon(Icons.logout, color: Hawks.textMuted)),
        ],
      ),
      body: RefreshIndicator(
        color: Hawks.gold,
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(api.shopName,
                style: const TextStyle(
                    color: Hawks.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const Text('Shop overview',
                style: TextStyle(color: Hawks.textDim)),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: CircularProgressIndicator(color: Hawks.gold)));
                }
                if (snap.hasError) {
                  return _errorCard();
                }
                final s = snap.data ?? {};
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _stat('Open Jobs', '${s['open_jobs'] ?? 0}', Hawks.gold),
                    _stat('New Orders', '${s['open_orders'] ?? 0}', Hawks.blue),
                    _stat('Low Stock', '${s['low_stock'] ?? 0}',
                        (s['low_stock'] ?? 0) > 0 ? Hawks.red : Hawks.green),
                    _stat('Products', '${s['products'] ?? 0}', Hawks.textMuted),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _navTile(Icons.inventory_2, 'Inventory',
                'Stock levels & quick adjust', const InventoryScreen()),
            _navTile(Icons.shopping_cart, 'Orders', 'Product sales & status',
                const OrdersScreen()),
            _navTile(Icons.build, 'Jobs', 'Harness & tuning work',
                const JobsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Hawks.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Hawks.border),
      ),
      child: Row(
        children: [
          Container(width: 5, decoration: BoxDecoration(color: accent)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Hawks.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        color: Hawks.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String title, String sub, Widget screen) {
    return Card(
      color: Hawks.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Hawks.border)),
      child: ListTile(
        leading: Icon(icon, color: Hawks.gold, size: 30),
        title: Text(title,
            style: const TextStyle(
                color: Hawks.text, fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(sub, style: const TextStyle(color: Hawks.textDim)),
        trailing: const Icon(Icons.chevron_right, color: Hawks.textMuted),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => screen))
            .then((_) => _reload()),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Hawks.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Hawks.red)),
      child: const Column(children: [
        Icon(Icons.wifi_off, color: Hawks.red, size: 36),
        SizedBox(height: 8),
        Text('Can\'t reach the shop PC.',
            style: TextStyle(color: Hawks.text, fontWeight: FontWeight.bold)),
        Text('Make sure it\'s on and you\'re on the same Wi-Fi.',
            style: TextStyle(color: Hawks.textDim), textAlign: TextAlign.center),
      ]),
    );
  }
}
