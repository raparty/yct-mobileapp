import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/content_service.dart';

class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});
  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  List<YctCenter> _centers = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final c = await ContentService.fetchCenters();
    if (mounted) setState(() { _centers = c; _loading = false; });
  }

  List<YctCenter> get _filtered => _search.isEmpty
      ? _centers
      : _centers.where((c) =>
          c.city.toLowerCase().contains(_search.toLowerCase()) ||
          c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.address.toLowerCase().contains(_search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Our Centers'), backgroundColor: AppColors.primary),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search by city or area...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(children: [
                  Text('${_filtered.length} centers',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMid, fontWeight: FontWeight.w500)),
                ])),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ContentService.clearCache();
                    await _load();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CenterCard(center: _filtered[i]),
                  ),
                ),
              ),
            ]),
    );
  }
}

class _CenterCard extends StatelessWidget {
  final YctCenter center;
  const _CenterCard({required this.center});

  Future<void> _call() async {
    final phone = center.phone.split(',').first.trim().replaceAll(' ', '');
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _maps() async {
    final query = Uri.encodeComponent('${center.name} ${center.city} Yoga Consciousness Trust');
    final uri = Uri.parse('https://maps.google.com/?q=$query');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: center.isHQ ? AppColors.primary : AppColors.border,
          width: center.isHQ ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(center.city,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: center.isHQ ? AppColors.primary : AppColors.textDark))),
            if (center.isHQ) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Text('HQ', style: TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 3),
          Text(center.name, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text(center.address,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4))),
          ]),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text(center.phone,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: _call,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.phone, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Call', style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                ]),
              ))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _maps,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFE6F1FB), borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.map_outlined, size: 14, color: AppColors.blue),
                  SizedBox(width: 4),
                  Text('Map', style: TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w500)),
                ]),
              )),
          ]),
        ]),
      ),
    );
  }
}
