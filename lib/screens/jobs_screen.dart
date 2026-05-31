import 'package:flutter/material.dart';
import '../theme.dart';
import '../api.dart';

const kJobStatuses = [
  'Open',
  'Quoted',
  'Awaiting Parts',
  'In Progress',
  'Ready',
  'Done',
  'Cancelled'
];

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final api = ApiService.instance;
  List<dynamic> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final j = await api.jobs();
      if (!mounted) return;
      setState(() {
        _jobs = j;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(Map job) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Hawks.surface,
      builder: (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${job['no']} — set status',
                  style: const TextStyle(
                      color: Hawks.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            for (final s in kJobStatuses)
              ListTile(
                leading: Icon(Icons.circle, color: Hawks.status(s), size: 14),
                title: Text(s, style: const TextStyle(color: Hawks.text)),
                onTap: () => Navigator.pop(ctx, s),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (status == null) return;
    try {
      await api.setJobStatus(job['id'], status);
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
          title: const Text('Jobs',
              style: TextStyle(color: Hawks.text, fontWeight: FontWeight.bold))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Hawks.gold))
          : RefreshIndicator(
              color: Hawks.gold,
              onRefresh: _load,
              child: _jobs.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      Center(
                          child: Text('No jobs.',
                              style: TextStyle(color: Hawks.textDim)))
                    ])
                  : ListView.separated(
                      itemCount: _jobs.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: Hawks.border),
                      itemBuilder: (context, i) {
                        final j = _jobs[i];
                        return ListTile(
                          title: Text(j['title'],
                              style: const TextStyle(
                                  color: Hawks.text,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text('${j['no']}  ·  ${j['customer']}',
                              style: const TextStyle(
                                  color: Hawks.textDim, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(api.money(j['total'] ?? 0),
                                  style: const TextStyle(color: Hawks.text)),
                              Text(j['status'],
                                  style: TextStyle(
                                      color: Hawks.status(j['status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          onTap: () => _changeStatus(j),
                        );
                      },
                    ),
            ),
    );
  }
}
