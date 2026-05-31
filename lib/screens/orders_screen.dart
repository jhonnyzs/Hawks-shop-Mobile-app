import 'package:flutter/material.dart';
import '../theme.dart';
import '../api.dart';

const kOrderStatuses = ['New', 'Paid', 'Fulfilled', 'Cancelled'];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final api = ApiService.instance;
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final o = await api.orders();
      if (!mounted) return;
      setState(() {
        _orders = o;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(Map order) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Hawks.surface,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${order['no']} — set status',
                style: const TextStyle(
                    color: Hawks.gold, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          for (final s in kOrderStatuses)
            ListTile(
              leading: Icon(Icons.circle, color: Hawks.status(s), size: 14),
              title: Text(s, style: const TextStyle(color: Hawks.text)),
              onTap: () => Navigator.pop(ctx, s),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
    if (status == null) return;
    try {
      await api.setOrderStatus(order['id'], status);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Orders',
              style: TextStyle(color: Hawks.text, fontWeight: FontWeight.bold))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Hawks.gold))
          : RefreshIndicator(
              color: Hawks.gold,
              onRefresh: _load,
              child: _orders.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      Center(
                          child: Text('No orders.',
                              style: TextStyle(color: Hawks.textDim)))
                    ])
                  : ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: Hawks.border),
                      itemBuilder: (context, i) {
                        final o = _orders[i];
                        return ListTile(
                          title: Text(o['customer'],
                              style: const TextStyle(color: Hawks.text)),
                          subtitle: Text(o['no'],
                              style: const TextStyle(
                                  color: Hawks.textDim, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(api.money(o['total'] ?? 0),
                                  style: const TextStyle(
                                      color: Hawks.text,
                                      fontWeight: FontWeight.bold)),
                              Text(o['status'],
                                  style: TextStyle(
                                      color: Hawks.status(o['status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          onTap: () => _changeStatus(o),
                        );
                      },
                    ),
            ),
    );
  }
}
