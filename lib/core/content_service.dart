// ─────────────────────────────────────────
// YCT — Content Service
// Fetches Gurudev, About YCT, Centers and
// Contact details from Firestore so updates
// don't require a new app release.
//
// Firestore structure:
//   settings/gurudev   → GurudevContent
//   settings/about     → AboutContent
//   settings/contact   → ContactContent
//   centers (collection) → List<YctCenter>
// ─────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Models ──────────────────────────────

class GurudevContent {
  final String aboutParagraph1;
  final String aboutParagraph2;
  final String aboutParagraph3;
  final String avSection;
  final String avParagraph1;
  final String avParagraph2;
  final String teachingsIntro;
  final List<String> teachingsBullets;
  final String legacyText;

  const GurudevContent({
    required this.aboutParagraph1,
    required this.aboutParagraph2,
    required this.aboutParagraph3,
    required this.avSection,
    required this.avParagraph1,
    required this.avParagraph2,
    required this.teachingsIntro,
    required this.teachingsBullets,
    required this.legacyText,
  });

  // Hardcoded fallback — shown if Firestore is unavailable
  factory GurudevContent.fallback() => const GurudevContent(
    aboutParagraph1:
      'Yogacharya Sri Raparthi Rama Rao is a revered spiritual master in the Himalayan tradition of Sri Ramlal Prabhuji. He is the founder of Yoga Consciousness Trust (YCT) and exponent of Anushtana Yoga Vedanta, an integrated approach to achieve goal of life, the Self Realization in this life itself.',
    aboutParagraph2:
      'Born with deep inclination towards spiritual practice, Gurudev dedicated his life to exploring the depths of yoga and Vedantic philosophy, ultimately synthesising these into the comprehensive system of Anushtana Yoga Vedanta — a practical path for self-realisation accessible to all.',
    aboutParagraph3:
      'Under his guidance, YCT has grown from a small Ashram in Vizinigiri to an organisation with centres across Andhra Pradesh and Telangana, affiliated with multiple Universities and serving thousands of seekers.',
    avSection: 'Anushtana Yoga Vedanta',
    avParagraph1:
      'Anushtana Yoga Vedanta is the methodology developed by Gurudev that integrates the practical aspects of Yoga — including asana, pranayama, dharana and dhyana — with the philosophical wisdom of Vedanta.',
    avParagraph2:
      'This integrated approach enables the practitioner to purify the body and mind, develop discriminative wisdom (viveka), and ultimately realise the true nature of the Self (Atma Sakshatkar).',
    teachingsIntro:
      'Gurudev\'s teachings are preserved in the monthly journal "Yoga Chaitanya Prabha" (యోగ చైతన్య ప్రభ), numerous books in Telugu and English, and thousands of audio discourses.\n\nKey teachings include:',
    teachingsBullets: [
      'The nature of karma and its role in spiritual evolution',
      'Practical techniques for meditation and self-enquiry',
      'Integration of four paths: Karma Yoga, Raja Yoga, Bhakti Yoga and Jnana Yoga',
      'The importance of Guru-Shishya relationship',
      'Vedantic understanding of Consciousness and Reality',
    ],
    legacyText:
      'Gurudev\'s Birthday is observed on 30th September each year, when thousands of devotees gather at Yoga Chaitanyaramam, Vizinigiri. He attained Maha Samadhi on 8th October, 2014.\n\n'
      'Initiated by Gurudev, YCT performs collective Upanayanams to all irrespective of caste, creed and gender.\n\n'
      'His teachings continue through YCT\'s network of institutes, residential programmes, and publications that reach seekers across the world.',
  );

  factory GurudevContent.fromFirestore(Map<String, dynamic> d) => GurudevContent(
    aboutParagraph1:   d['about_p1']           ?? GurudevContent.fallback().aboutParagraph1,
    aboutParagraph2:   d['about_p2']           ?? GurudevContent.fallback().aboutParagraph2,
    aboutParagraph3:   d['about_p3']           ?? GurudevContent.fallback().aboutParagraph3,
    avSection:         d['av_section']         ?? GurudevContent.fallback().avSection,
    avParagraph1:      d['av_p1']              ?? GurudevContent.fallback().avParagraph1,
    avParagraph2:      d['av_p2']              ?? GurudevContent.fallback().avParagraph2,
    teachingsIntro:    d['teachings_intro']    ?? GurudevContent.fallback().teachingsIntro,
    teachingsBullets:  List<String>.from(d['teachings_bullets'] ?? GurudevContent.fallback().teachingsBullets),
    legacyText:        d['legacy_text']        ?? GurudevContent.fallback().legacyText,
  );
}

class AboutContent {
  final String mission;
  final List<String> institutes;
  final List<String> programmes;
  final String publications;

  const AboutContent({
    required this.mission,
    required this.institutes,
    required this.programmes,
    required this.publications,
  });

  factory AboutContent.fallback() => const AboutContent(
    mission:
      'To spread the ancient wisdom of Anushtana Yoga Vedanta to all seekers, making the path of self-realisation accessible through practical teaching, residential programmes and publications.',
    institutes: [
      'Academy of Yoga Consciousness, Bhimili — Affiliated to Andhra University',
      'International Institute of Yoga Research & Training, Bhimili',
      'Sri Raparti Rama Institute of Yoga, Kanavaram — Affiliated to Adi Kavi Nannaya University',
      'Sri Raparti Rama Academy of Yogic Sciences, Nandyal — Affiliated to Rayalaseema University',
    ],
    programmes: [
      'Antar Mouna — Silent retreat',
      'Chaitanya Prakasha Yoga — Dharana & Meditation',
      'Anusthana Yoga Vedanta Course (AYVC)',
      'One Year PG Diploma in Yoga affiliated to various Universities',
      'Three Month Yoga Certificate Course',
      'Health Management Camps through Yoga',
      'Personality Development Camps for Children',
      'Life Skill Development Camps for Youth',
      'Sadhana Saptaha — 7-day intensive spiritual retreats',
    ],
    publications:
      'YCT publishes the bi-lingual monthly journal "Yoga Chaitanya Prabha" (యోగ చైతన్య ప్రభ) since 1996, along with numerous books in Telugu, English and bilingual formats covering the complete teachings of Anushtana Yoga Vedanta.',
  );

  factory AboutContent.fromFirestore(Map<String, dynamic> d) => AboutContent(
    mission:      d['mission']      ?? AboutContent.fallback().mission,
    institutes:   List<String>.from(d['institutes']  ?? AboutContent.fallback().institutes),
    programmes:   List<String>.from(d['programmes']  ?? AboutContent.fallback().programmes),
    publications: d['publications'] ?? AboutContent.fallback().publications,
  );
}

class YctCenter {
  final String city;
  final String name;
  final String address;
  final String phone;
  final bool isHQ;
  final int sortOrder;

  const YctCenter({
    required this.city,
    required this.name,
    required this.address,
    required this.phone,
    required this.isHQ,
    required this.sortOrder,
  });

  factory YctCenter.fromFirestore(Map<String, dynamic> d) => YctCenter(
    city:      d['city']       ?? '',
    name:      d['name']       ?? '',
    address:   d['address']    ?? '',
    phone:     d['phone']      ?? '',
    isHQ:      d['is_hq']      ?? false,
    sortOrder: d['sort_order'] ?? 99,
  );
}

class ContactContent {
  final String website;
  final String whatsapp;
  final String email;
  final String phone;

  const ContactContent({
    required this.website,
    required this.whatsapp,
    required this.email,
    required this.phone,
  });

  factory ContactContent.fallback() => const ContactContent(
    website:  'https://www.yogaconsciousness.org',
    whatsapp: 'https://wa.me/919492448840',
    email:    'info@yogaconsciousness.org',
    phone:    '+91 89662 68923',
  );

  factory ContactContent.fromFirestore(Map<String, dynamic> d) => ContactContent(
    website:  d['website']  ?? ContactContent.fallback().website,
    whatsapp: d['whatsapp'] ?? ContactContent.fallback().whatsapp,
    email:    d['email']    ?? ContactContent.fallback().email,
    phone:    d['phone']    ?? ContactContent.fallback().phone,
  );
}

// ── Service ─────────────────────────────

class ContentService {
  static final _db = FirebaseFirestore.instance;
  static const _timeout = Duration(seconds: 12);

  // Cache so repeated navigation doesn't re-fetch
  static GurudevContent? _gurudevCache;
  static AboutContent?   _aboutCache;
  static ContactContent? _contactCache;
  static List<YctCenter>? _centersCache;

  static Future<GurudevContent> fetchGurudev() async {
    if (_gurudevCache != null) return _gurudevCache!;
    try {
      final doc = await _db.collection('settings').doc('gurudev')
          .get().timeout(_timeout);
      _gurudevCache = doc.exists
          ? GurudevContent.fromFirestore(doc.data()!)
          : GurudevContent.fallback();
    } catch (_) {
      _gurudevCache = GurudevContent.fallback();
    }
    return _gurudevCache!;
  }

  static Future<AboutContent> fetchAbout() async {
    if (_aboutCache != null) return _aboutCache!;
    try {
      final doc = await _db.collection('settings').doc('about')
          .get().timeout(_timeout);
      _aboutCache = doc.exists
          ? AboutContent.fromFirestore(doc.data()!)
          : AboutContent.fallback();
    } catch (_) {
      _aboutCache = AboutContent.fallback();
    }
    return _aboutCache!;
  }

  static Future<List<YctCenter>> fetchCenters() async {
    if (_centersCache != null) return _centersCache!;
    try {
      final snap = await _db.collection('centers')
          .get().timeout(_timeout);
      final list = snap.docs
          .map((d) => YctCenter.fromFirestore(d.data()))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _centersCache = list.isEmpty ? _fallbackCenters() : list;
    } catch (_) {
      _centersCache = _fallbackCenters();
    }
    return _centersCache!;
  }

  static Future<ContactContent> fetchContact() async {
    if (_contactCache != null) return _contactCache!;
    try {
      final doc = await _db.collection('settings').doc('contact')
          .get().timeout(_timeout);
      _contactCache = doc.exists
          ? ContactContent.fromFirestore(doc.data()!)
          : ContactContent.fallback();
    } catch (_) {
      _contactCache = ContactContent.fallback();
    }
    return _contactCache!;
  }

  // Clear cache — call when admin makes changes
  static void clearCache() {
    _gurudevCache  = null;
    _aboutCache    = null;
    _contactCache  = null;
    _centersCache  = null;
  }

  // Hardcoded fallback centers — shown if Firestore unavailable
  static List<YctCenter> _fallbackCenters() => const [
    YctCenter(city: 'Vizinigiri — Head Quarters', name: 'Yoga Chaitanyaramam',
      address: 'Vizinigiri, Jami Mandal, Vizianagaram Dt. – 535250',
      phone: '+91 8966268923', isHQ: true, sortOrder: 0),
    YctCenter(city: 'Vizianagaram', name: 'Yoga Consciousness Trust',
      address: '# 20-21-19/3, Vinayak Nagar, Ring Road, Near Bhashyam School, Vizianagaram – 535002',
      phone: '+91 9247839399', isHQ: false, sortOrder: 1),
    YctCenter(city: 'Srikakulam', name: 'Yoga Consciousness Trust',
      address: 'LIG-1-53, Near Old TMPH School, APHB Colony, Srikakulam',
      phone: '+91 8247576122, +91 9963230973', isHQ: false, sortOrder: 2),
    YctCenter(city: 'Bheemili', name: 'International Institute of Yoga Research & Training',
      address: 'Yoga Chaitanyagiri, Krishna Colony, Dorathota Road, Bheemili – 531163',
      phone: '+91 8933228222, +91 94406 43531', isHQ: false, sortOrder: 3),
    YctCenter(city: 'Visakhapatnam — VUDA Park', name: 'Yoga Consciousness Trust',
      address: 'Phase II, New VUDA Park, Beach Road, Visakhapatnam – 530023',
      phone: '+91 9440179914', isHQ: false, sortOrder: 4),
    YctCenter(city: 'Visakhapatnam — Lalitha Nagar', name: 'Yoga Consciousness Trust',
      address: 'Sri Krishna Vidhya Mandir, Lalitha Temple Road, Lalitha Nagar, Visakhapatnam – 16',
      phone: '+91 9492534323', isHQ: false, sortOrder: 5),
    YctCenter(city: 'Visakhapatnam — Seethammadhara', name: 'Yoga Consciousness Trust',
      address: 'Tamil Kalai Mandram, Abhaya Anjaneya Temple Road, Seethammadhara, Visakhapatnam',
      phone: '+91 9959031988', isHQ: false, sortOrder: 6),
    YctCenter(city: 'Visakhapatnam — Gajuwaka', name: 'Yoga Consciousness Trust',
      address: 'D No: 27-36-1/4, Street No 2, Chaitanya Nagar, Behind CMR Central, Gajuwaka, Visakhapatnam',
      phone: '+91 9705813160', isHQ: false, sortOrder: 7),
    YctCenter(city: 'Visakhapatnam — Madhurawada', name: 'Yoga Consciousness Trust',
      address: 'Midhilapuri VUDA Colony, Bank of India side Road, Madhurawada, Visakhapatnam',
      phone: '+91 7981652319', isHQ: false, sortOrder: 8),
    YctCenter(city: 'Hyderabad — Kondapur', name: 'Yoga Chaitanya Sadanam',
      address: 'Plot No. 347, H.M.D.A. Colony, Kondapur Village, Ghatkesar Mandal',
      phone: '+91 98496 48102', isHQ: false, sortOrder: 9),
    YctCenter(city: 'Hyderabad — Uppal', name: 'Yoga Consciousness Trust',
      address: 'East Kalyanpuri Community Hall, Uppal',
      phone: '+91 8801375881', isHQ: false, sortOrder: 10),
    YctCenter(city: 'Nandyal', name: 'Yoga Chaitanya Kendra',
      address: 'Yoga Chaitanya Nagar, Baratha Matha Temple Road, Tekke, Nandyal, Kurnool Dt. – 518501',
      phone: '+91 8919771823, +91 7396962838', isHQ: false, sortOrder: 11),
    YctCenter(city: 'Kurnool', name: 'Yoga Consciousness Trust',
      address: 'Kurnool, Andhra Pradesh',
      phone: '+91 8639366445', isHQ: false, sortOrder: 12),
    YctCenter(city: 'Kanavaram — Godavari', name: 'Yoga Consciousness Trust',
      address: 'Rajugari Thota, Kanavaram Village, Rajanagaram Mandal, East Godavari District',
      phone: '+91 7382308440', isHQ: false, sortOrder: 13),
    YctCenter(city: 'Kakinada — Santhi Nagar', name: 'Yoga Consciousness Trust',
      address: '3-16c-33, Santhi Nagar, Kakinada, East Godavari District',
      phone: '+91 9849340359', isHQ: false, sortOrder: 14),
    YctCenter(city: 'Kakinada — Rama Rao Peta', name: 'Yoga Consciousness Trust',
      address: 'Gayatri Bhavan, Rama Rao Peta, Kakinada',
      phone: '+91 9849898934', isHQ: false, sortOrder: 15),
    YctCenter(city: 'Eluru', name: 'Yoga Consciousness Trust',
      address: 'Prasanthi Hospital, 3rd Floor, Near New Bus Stand, Opp. Bhashyam School, NR Pet, Eluru',
      phone: '+91 9491606925', isHQ: false, sortOrder: 16),
  ];
}
