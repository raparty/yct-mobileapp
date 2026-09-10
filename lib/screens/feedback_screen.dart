import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/firestore_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl   = TextEditingController();
  String _category = 'General';
  bool _submitting = false;
  bool _submitted  = false;

  static const _categories = [
    'General',
    'App Issue',
    'Content Request',
    'Program Enquiry',
    'Suggestion',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await FirestoreService.submitFeedback(
        name:     _nameCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim(),
        message:  _msgCtrl.text.trim(),
        category: _category,
      );
      if (mounted) setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not submit. Please try again.'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: AppColors.primary),
      body: _submitted ? _successView() : _formView(),
    );
  }

  Widget _successView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: AppColors.primary, size: 36)),
        const SizedBox(height: 20),
        const Text('Thank You!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.textDark)),
        const SizedBox(height: 10),
        const Text(
          'Your feedback has been received.\nThe YCT team will get back to you if needed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMid, height: 1.5)),
        const SizedBox(height: 28),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back',
            style: TextStyle(color: AppColors.primary))),
      ]),
    ),
  );

  Widget _formView() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2))),
          child: const Row(children: [
            Icon(Icons.favorite_outline, color: AppColors.primary, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(
              'We value your feedback. Your message goes directly to the YCT team.',
              style: TextStyle(fontSize: 12, color: AppColors.primaryDark,
                height: 1.4))),
          ]),
        ),
        const SizedBox(height: 20),

        // Category
        const Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMid, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _categories.map((c) => GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _category == c ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _category == c ? AppColors.primary : AppColors.border)),
              child: Text(c, style: TextStyle(
                fontSize: 12,
                color: _category == c ? Colors.white : AppColors.textMid,
                fontWeight: _category == c ? FontWeight.w600 : FontWeight.normal)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),

        // Name
        const Text('YOUR NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMid, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecor('Full name', Icons.person_outline),
          validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),

        // Phone
        const Text('PHONE (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMid, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
          decoration: _inputDecor('Mobile number', Icons.phone_outlined),
        ),
        const SizedBox(height: 16),

        // Message
        const Text('YOUR MESSAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMid, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _msgCtrl,
          maxLines: 5,
          maxLength: 500,
          decoration: _inputDecor(
            'Write your feedback, suggestion or query...',
            Icons.edit_outlined),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter your message';
            if (v.trim().length < 10) return 'Please write at least 10 characters';
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Submit
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0),
            child: _submitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Text('Submit Feedback',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    ),
  );

  InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
    prefixIcon: Icon(icon, color: AppColors.textMid, size: 18),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1.5)),
  );
}
