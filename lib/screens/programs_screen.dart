import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});
  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  List<YearlyProgram> _all = [];
  bool _loading = true;
  String? _error;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await FirestoreService.fetchPrograms();
      if (mounted) setState(() { _all = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Could not load programs. Pull to refresh.';
        _loading = false;
      });
    }
  }

  List<YearlyProgram> get _upcoming =>
      _all.where((p) => p.isUpcoming).toList();

  List<YearlyProgram> get _past =>
      _all.where((p) => !p.isUpcoming).toList().reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Programs'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.saffron,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Past (${_past.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _ProgramList(
                        programs: _upcoming,
                        emptyMessage: 'No upcoming programs.\nCheck back soon.',
                      ),
                      _ProgramList(
                        programs: _past,
                        emptyMessage: 'No past programs yet.',
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ProgramList extends StatelessWidget {
  final List<YearlyProgram> programs;
  final String emptyMessage;
  const _ProgramList({required this.programs, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.event_outlined, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(emptyMessage, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: programs.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ProgramCard(program: programs[i]),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final YearlyProgram program;
  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Type badge bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: program.typeColor.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(
              bottom: BorderSide(color: program.typeColor.withOpacity(0.2))),
          ),
          child: Row(children: [
            Icon(program.typeIcon, size: 14, color: program.typeColor),
            const SizedBox(width: 6),
            Text(program.typeLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: program.typeColor)),
            const Spacer(),
            if (program.isUpcoming)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10)),
                child: const Text('Upcoming',
                  style: TextStyle(fontSize: 9, color: Colors.white,
                    fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(program.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
            if (program.titleTelugu.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(program.titleTelugu,
                style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
            ],
            const SizedBox(height: 10),
            _InfoRow(Icons.calendar_today_outlined, program.displayDate),
            const SizedBox(height: 5),
            _InfoRow(
              Icons.location_on_outlined,
              program.centerName.isNotEmpty && program.location.isNotEmpty
                  ? '${program.centerName} · ${program.location}'
                  : program.centerName.isNotEmpty
                      ? program.centerName
                      : program.location,
            ),
            if (program.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Text(program.description,
                style: const TextStyle(fontSize: 12, color: AppColors.textLight,
                  height: 1.5)),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13, color: AppColors.textMid),
      const SizedBox(width: 6),
      Expanded(child: Text(text,
        style: const TextStyle(fontSize: 12, color: AppColors.textMid))),
    ]);
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
      const SizedBox(height: 16),
      TextButton(onPressed: onRetry,
        child: const Text('Try Again',
          style: TextStyle(color: AppColors.primary))),
    ]));
}
