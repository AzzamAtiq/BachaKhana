// ═══════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: 40.0, end: 0.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.greenMid, AppColors.greenDark],
            begin: Alignment.topRight, end: Alignment.bottomLeft)),
        child: SafeArea(child: FadeTransition(opacity: _fade,
          child: AnimatedBuilder(animation: _slide,
            builder: (_, child) =>
              Transform.translate(offset: Offset(0, _slide.value), child: child),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(children: [
                const SizedBox(height: 80),
                Container(width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.2))),
                  child: const Center(child: Text('🍱', style: TextStyle(fontSize: 52)))),
                const SizedBox(height: 22),
                Text('BachaKhana', style: GoogleFonts.sora(fontSize: 34,
                  fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 6),
                Text('بچا کھانا', style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 20, color: Colors.white54)),
                const SizedBox(height: 10),
                Text('Rawalpindi & Islamabad ka\nfood waste solution 🌿',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(fontSize: 13, color: Colors.white54, height: 1.6)),
                const SizedBox(height: 48),
                Row(children: [
                  _stat('12+', 'Restaurants'),
                  _stat('70%', 'Tak Bachat'),
                  _stat('100%', 'Halal'),
                ]),
                const Spacer(),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Shuru Karein →'))),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w500)),
                    onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const MainScreen())),
                    child: const Text('Pehle Dekhein'))),
                const SizedBox(height: 40),
              ]),
            ))),
      ),
    );
  }

  Widget _stat(String val, String lbl) => Expanded(
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12))),
      child: Column(children: [
        Text(val, style: GoogleFonts.sora(fontSize: 18,
          fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 3),
        Text(lbl, style: GoogleFonts.sora(fontSize: 9, color: Colors.white54),
          textAlign: TextAlign.center),
      ])));
}
