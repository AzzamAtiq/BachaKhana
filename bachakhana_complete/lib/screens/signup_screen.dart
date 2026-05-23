// signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final _name=TextEditingController(), _phone=TextEditingController(),
        _email=TextEditingController(), _pass=TextEditingController();
  String _city='Rawalpindi'; bool _obs=true,_loading=false; String? _err;

  @override void dispose() { [_name,_phone,_email,_pass].forEach((c)=>c.dispose()); super.dispose(); }

  Future<void> _signup() async {
    if (_name.text.trim().isEmpty) { setState(()=>_err='Naam likhein.'); return; }
    if (_email.text.trim().isEmpty) { setState(()=>_err='Email likhein.'); return; }
    if (_pass.text.length<6) { setState(()=>_err='Password 6+ chars ka hona chahiye.'); return; }
    setState(()=>_loading=true);
    final s=context.read<AppState>();
    await s.signup(name:_name.text,email:_email.text,password:_pass.text,phone:_phone.text,city:_city);
    if (!mounted) return;
    if (s.error!=null) { setState(()=>_err=s.error); s.clearError(); setState(()=>_loading=false); }
    else Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>const MainScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: Column(children: [
    Container(decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [AppColors.greenMid, AppColors.green],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(bottom:false, child: Padding(
        padding: const EdgeInsets.fromLTRB(24,16,24,40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap:()=>Navigator.pop(context),
            child: Container(width:36,height:36,
              decoration: BoxDecoration(color:Colors.white.withOpacity(0.15),borderRadius:BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back,color:Colors.white,size:18))),
          const SizedBox(height:24),
          Text('Account Banayein 🎉', style: GoogleFonts.sora(fontSize:26,fontWeight:FontWeight.w800,color:Colors.white,letterSpacing:-0.5)),
          const SizedBox(height:6),
          Text('Bilkul free — sirf 30 second', style:GoogleFonts.sora(fontSize:13,color:Colors.white60)),
        ])))),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_err!=null) ...[
          Container(width:double.infinity, padding:const EdgeInsets.all(12),
            decoration: BoxDecoration(color:AppColors.redPale,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFFECACA))),
            child: Text('⚠️ $_err', style:GoogleFonts.sora(fontSize:12,color:AppColors.red))),
          const SizedBox(height:16),
        ],
        _f('Naam *',_name,'Ahmad Ali',TextInputType.name,Icons.person_outline),
        const SizedBox(height:12),
        _f('Phone',_phone,'+92 300 1234567',TextInputType.phone,Icons.phone_android),
        const SizedBox(height:12),
        _f('Email *',_email,'aap@email.com',TextInputType.emailAddress,Icons.email_outlined),
        const SizedBox(height:12),
        Text('Password *', style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
        const SizedBox(height:6),
        TextField(controller:_pass, obscureText:_obs, style:GoogleFonts.sora(fontSize:13),
          decoration: InputDecoration(hintText:'••••••••',
            prefixIcon: const Icon(Icons.lock_outline,size:20,color:AppColors.gray),
            suffixIcon: IconButton(icon: Icon(_obs?Icons.visibility_off:Icons.visibility,size:18,color:AppColors.gray),
              onPressed:()=>setState(()=>_obs=!_obs)))),
        const SizedBox(height:12),
        Text('Shahar *', style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
        const SizedBox(height:6),
        DropdownButtonFormField<String>(value:_city, decoration: const InputDecoration(),
          items:['Rawalpindi','Islamabad'].map((c)=>DropdownMenuItem(value:c,child:Text(c,style:GoogleFonts.sora(fontSize:13)))).toList(),
          onChanged:(v)=>setState(()=>_city=v!)),
        const SizedBox(height:24),
        SizedBox(width:double.infinity, child: ElevatedButton(
          onPressed:_loading?null:_signup,
          child:_loading ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2))
            : const Text('Account Banao →'))),
        const SizedBox(height:16),
        Center(child:GestureDetector(onTap:()=>Navigator.pop(context),
          child:RichText(text:TextSpan(children:[
            TextSpan(text:'Pehle se account hai? ',style:GoogleFonts.sora(fontSize:13,color:AppColors.gray)),
            TextSpan(text:'Login Karein',style:GoogleFonts.sora(fontSize:13,color:AppColors.greenMid,fontWeight:FontWeight.w700)),
          ])))),
      ]))),
  ]));

  Widget _f(String lbl, TextEditingController c, String hint, TextInputType t, IconData ico) =>
    Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Text(lbl, style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
      const SizedBox(height:6),
      TextField(controller:c, keyboardType:t, style:GoogleFonts.sora(fontSize:13),
        decoration: InputDecoration(hintText:hint, prefixIcon: Icon(ico,size:20,color:AppColors.gray))),
    ]);
}
