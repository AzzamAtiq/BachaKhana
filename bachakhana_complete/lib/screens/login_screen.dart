import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obs = true, _loading = false;
  String? _err;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _err = 'Email aur password likhein.'); return;
    }
    setState(() { _loading = true; _err = null; });
    final s = context.read<AppState>();
    await s.login(_email.text, _pass.text);
    if (!mounted) return;
    if (s.error != null) { setState(() { _err = s.error; _loading = false; }); s.clearError(); }
    else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppColors.greenMid, AppColors.green],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18))),
            const SizedBox(height: 24),
            Text('Khush Aamdeed! 👋', style: GoogleFonts.sora(fontSize: 26,
              fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('Apna account mein login karein',
              style: GoogleFonts.sora(fontSize: 13, color: Colors.white60)),
          ])))),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          if (_err != null) ...[
            Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.redPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA))),
              child: Text('⚠️ $_err',
                style: GoogleFonts.sora(fontSize: 12, color: AppColors.red))),
            const SizedBox(height: 16),
          ],
          _lbl('Email'),
          const SizedBox(height: 6),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.sora(fontSize: 13),
            decoration: const InputDecoration(hintText: 'aap@email.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.gray))),
          const SizedBox(height: 16),
          _lbl('Password'),
          const SizedBox(height: 6),
          TextField(controller: _pass, obscureText: _obs,
            style: GoogleFonts.sora(fontSize: 13), onSubmitted: (_) => _login(),
            decoration: InputDecoration(hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.gray),
              suffixIcon: IconButton(
                icon: Icon(_obs ? Icons.visibility_off : Icons.visibility,
                  size: 18, color: AppColors.gray),
                onPressed: () => setState(() => _obs = !_obs)))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: _loading ? null : _login,
              child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Login Karein →'))),
          const SizedBox(height: 20),
          Center(child: GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignupScreen())),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Naya account? ',
                style: GoogleFonts.sora(fontSize: 13, color: AppColors.gray)),
              TextSpan(text: 'Register Karein',
                style: GoogleFonts.sora(fontSize: 13, color: AppColors.greenMid,
                  fontWeight: FontWeight.w700)),
            ])))),
        ]))),
    ]));
  }
  Widget _lbl(String t) => Text(t, style: GoogleFonts.sora(
    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.charcoal));
}
