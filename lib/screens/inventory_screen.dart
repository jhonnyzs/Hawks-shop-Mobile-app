import 'package:flutter/material.dart';
import '../theme.dart';
import '../api.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final api = ApiService.instance;
  List<dynamic> _items = [];
  bool _loading = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await api.inventory(_q);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _qtyColor(num qty, num reorder) {
    if (reorder > 0 && qty <= reorder) return qty <= 0 ? Hawks.red : Hawks.amber;
    return Hawks.green;
  }

  Future<void> _adjust(Map item) async {
    final controller = TextEditingController();
    final reason = TextEditingController(text: 'Stock count');
    final delta = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Hawks.surface,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['name'],
                style: const TextStyle(
                    color: Hawks.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text('In stock now: ${item['qty']}',
                style: const TextStyle(color: Hawks.textMuted)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true, decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Change (e.g. 10 to add, -2 to remove)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reason,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, double.tryParse('5')),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Hawks.green,
                      side: const BorderSide(color: Hawks.green)),
                  child: const Text('+5'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(ctx, double.tryParse(controller.text)),
                  child: const Text('APPLY'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
    if (delta == null) return;
    try {
      await api.adjustStock(item['id'], delta,
          reason.text.isEmpty ? 'mobile' : reason.text);
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
          title: const Text('Inventory',
              style: TextStyle(color: Hawks.text, fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) {
                _q = v;
                _load();
              },
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Hawks.textDim),
                  hintText: 'Search SKU, name, category…'),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Hawks.gold))
                : RefreshIndicator(
                    color: Hawks.gold,
                    onRefresh: _load,
                    child: _items.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 80),
                            Center(
                                child: Text('No items.',
                                    style: TextStyle(color: Hawks.textDim)))
                          ])
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, color: Hawks.border),
                            itemBuilder: (context, i) {
                              final it = _items[i];
                              final qty = (it['qty'] ?? 0) as num;
                              final reorder = (it['reorder_level'] ?? 0) as num;
                              return ListTile(
                                title: Text(it['name'],
                                    style: const TextStyle(color: Hawks.text)),
                                subtitle: Text(
                                    '${it['sku'] ?? ''}  ·  ${it['category'] ?? ''}',
                                    style: const TextStyle(
                                        color: Hawks.textDim, fontSize: 12)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$qty',
                                        style: TextStyle(
                                            color: _qtyColor(qty, reorder),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    Text(api.money(it['price'] ?? 0),
                                        style: const TextStyle(
                                            color: Hawks.textMuted, fontSize: 12)),
                                  ],
                                ),
                                onTap: () => _adjust(it),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
