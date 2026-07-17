import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});
  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  String _search = '';

  static const _centers = [
    _Center('Vizinigiri — Head Quarters', 'Yoga Chaitanyaramam',
      'Vizinigiri, Jami Mandal, Vizianagaram Dt. – 535250',
      '+918966268923', true),
    _Center('Vizianagaram', 'Yoga Consciousness Trust',
      '# 20-21-19/3, Vinayak Nagar, Ring Road, Near Bhashyam School, Vizianagaram – 535002',
      '+919247839399', false),
    _Center('Srikakulam', 'Yoga Consciousness Trust',
      'Dr. B.R.Ambedkar Bhavan, Opposite Zilla Parishad, A.P.H.B Colony, Srikakulam',
      '+919963230973', false),
    _Center('Bheemili', 'International Institute of Yoga Research & Training',
      'Yoga Chaitanyagiri, Krishna Colony, Dorathota Road, Bheemili – 531163',
      '+918933228222', false),
    _Center('Visakhapatnam — Beach Road', 'Yoga Consciousness Trust',
      'Phase II, New VUDA Park, Beach Road, Visakhapatnam – 530023',
      '+919440179914', false),
    _Center('Visakhapatnam — Lalitha Nagar', 'Yoga Consciousness Trust',
      'Sri Krishna Vidhya Mandir, Lalitha Temple Road, Lalitha Nagar, Visakhapatnam – 16',
      '+919492534323', false),
    _Center('Visakhapatnam — Seethammadhara', 'Yoga Consciousness Trust',
      'Tamil Kalai Mandram, Abhaya Anjaneya Temple Road, Seethammadhara, Visakhapatnam',
      '+919959031988', false),
    _Center('Hyderabad — Kondapur', 'Yoga Chaitanya Sadanam',
      'Plot No. 347, H.M.D.A. Colony, Kondapur Village, Ghatkesar Mandal',
      '+918415329306', false),
    _Center('Hyderabad — Uppal', 'Yoga Consciousness Trust',
      'East Kalyanpuri Community Hall, Uppal',
      '+918801375881', false),
    _Center('Nandyal', 'Yoga Chaitanya Kendra',
      'Yoga Chaitanya Nagar, Baratha Matha Temple Road, Tekke, Nandyal, Kurnool Dt. – 518501',
      '+918919771823', false),
    _Center('Kurnool', 'Yoga Consciousness Trust',
      'Kurnool, Andhra Pradesh',
      '+918639366445', false),
    _Center('Kanavaram — Godavari', 'Yoga Consciousness Trust',
      'Rajugari Thota, Kanavaram Village, Rajanagaram Mandal, East Godavari District',
      '+919949203222', false),
    _Center('Kakinada', 'Yoga Consciousness Trust',
      '3-16c-33, Santhi Nagar, Kakinada, East Godavari District',
      '+919849340359', false),
    _Center('Rajahmundry', 'Yoga Consciousness Trust',
      'Dharmamchara Community Hall, Near Prakasam Round Park, Prakasam Nagar, Rajahmundry',
      '+917382308440', false),
    _Center('Eluru', 'Yoga Consciousness Trust',
      'Prasanthi Hospital, 3rd Floor, Near New Bus Stand, Opp. Bhashyam School, NR Pet, Eluru',
      '+919491606925', false),
  ];

  List<_Center> get _filtered => _search.isEmpty
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
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16,12,16,8),
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
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CenterCard(center: _filtered[i]),
          ),
        ),
      ]),
    );
  }
}

class _Center {
  final String city, name, address, phone;
  final bool isHQ;
  const _Center(this.city, this.name, this.address, this.phone, this.isHQ);
}

class _CenterCard extends StatelessWidget {
  final _Center center;
  const _CenterCard({required this.center});

  Future<void> _call() async {
    final uri = Uri.parse('tel:${center.phone}');
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
          const SizedBox(height: 10),
          Row(children: [
            // Call button
            Expanded(child: GestureDetector(
              onTap: _call,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.phone, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(center.phone.replaceFirst('+91', '+91 '),
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                ]),
              ))),
            const SizedBox(width: 8),
            // Maps button
            GestureDetector(
              onTap: _maps,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(8)),
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
