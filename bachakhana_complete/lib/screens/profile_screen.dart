import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final u  = st.currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(gradient: LinearGradient(
            colors: [AppColors.green, AppColors.greenMid],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [
              Container(width: 80, height: 80,
                decoration: BoxDecoration(color: AppColors.saffron,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 3)),
                child: Center(child: Text(
                  u != null && u.name.isNotEmpty ? u.name[0].toUpperCase() : 'A',
                  style: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(height: 10),
              Text(u?.name ?? 'Guest',
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 3),
              Text(u?.email ?? '',
                style: GoogleFonts.sora(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 20),
              // Stats
              Row(children: [
                _pst('${st.orders.length}', 'Orders'),
                const SizedBox(width: 6),
                _pst('Rs ${st.totalSaved}', 'Bachat'),
                const SizedBox(width: 6),
                _pst('🌿 ${st.orders.length}', 'CO₂'),
              ]),
              const SizedBox(height: 4),
            ])))),
        // Menu
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SizedBox(height: 4),
            _menuCard([
              _mi('👤', AppColors.greenPale, 'Profile Edit Karein', 'Naam, phone, address'),
              _mi('🔔', AppColors.bluePale, 'Notifications', 'Deal alerts on/off'),
              _mi('❤️', AppColors.saffronPale, 'Favorite Restaurants', 'Aap ke saved restaurants'),
              _mi('📍', AppColors.greenPale, 'Delivery Address', 'Ghar, office locations'),
            ]),
            const SizedBox(height: 14),
            _menuCard([
              _mi('💳', AppColors.bluePale, 'Payment Methods', 'JazzCash, EasyPaisa, Card'),
              _mi('🌿', AppColors.greenPale, 'Mera Impact', 'Kitna food waste bachaya'),
              _mi('⭐', AppColors.saffronPale, 'App Rate Karein', 'Play Store par review do'),
              _mi('❓', AppColors.bluePale, 'Help & Support', 'FAQ, contact us'),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  backgroundColor: AppColors.redPale,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                onPressed: () async {
                  await st.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()), (_) => false);
                  }
                },
                child: const Text('🚪 Logout'))),
            const SizedBox(height: 30),
          ]))),
      ]),
    );
  }

  Widget _pst(String val, String lbl) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(val, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(lbl, style: GoogleFonts.sora(fontSize: 9, color: Colors.white54)),
      ])));

  Widget _menuCard(List<Widget> items) => Container(
    decoration: cardDecoration(radius: 18), child: Column(children: items));

  Widget _mi(String ico, Color icoBg, String title, String sub) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: icoBg, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(ico, style: const TextStyle(fontSize: 18)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        Text(sub, style: GoogleFonts.sora(fontSize: 10, color: AppColors.lightGray)),
      ])),
      const Icon(Icons.chevron_right, color: AppColors.lightGray, size: 18),
    ]));
}
