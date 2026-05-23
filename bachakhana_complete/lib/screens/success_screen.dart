// success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'main_screen.dart';

class SuccessScreen extends StatefulWidget {
  final String orderId;
  final RestaurantModel restaurant;
  final SlotModel slot;
  final String selectedTime;
  final bool isDelivery;
  const SuccessScreen({super.key, required this.orderId, required this.restaurant,
    required this.slot, required this.selectedTime, required this.isDelivery});
  @override State<SuccessScreen> createState() => _SuccessScreenState();
}
class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync:this, duration:const Duration(milliseconds:700));
    _scale = CurvedAnimation(parent:_ctrl, curve:Curves.elasticOut);
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final saved = widget.slot.origPrice - widget.slot.bagPrice;
    return Scaffold(backgroundColor: AppColors.cream,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children:[
          const SizedBox(height:24),
          ScaleTransition(scale:_scale,
            child: Container(width:96,height:96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors:[AppColors.greenMid,AppColors.green]),
                borderRadius: BorderRadius.circular(28),
                boxShadow:[BoxShadow(color:AppColors.green.withOpacity(0.3),blurRadius:24,offset:const Offset(0,8))]),
              child: const Center(child:Text('✅',style:TextStyle(fontSize:48))))),
          const SizedBox(height:22),
          Text('Order Ho Gayi! 🎉', style:GoogleFonts.sora(fontSize:24,fontWeight:FontWeight.w900,color:AppColors.charcoal,letterSpacing:-0.5)),
          const SizedBox(height:8),
          Text('${r.name} se aaj ${widget.selectedTime} ke beech\napna Surprise Bag le aao!',
            textAlign:TextAlign.center,
            style:GoogleFonts.sora(fontSize:12,color:AppColors.gray,height:1.7)),
          const SizedBox(height:26),
          // QR Card
          Container(width:double.infinity, decoration:shadowDecoration(radius:22), padding:const EdgeInsets.all(20),
            child: Column(children:[
              Text('Restaurant Par Yeh QR Dikhayein',
                style:GoogleFonts.sora(fontSize:10,fontWeight:FontWeight.w700,color:AppColors.gray,letterSpacing:0.08)),
              const SizedBox(height:16),
              Container(width:120,height:120,
                decoration:BoxDecoration(color:AppColors.charcoal,borderRadius:BorderRadius.circular(14)),
                child: GridView.builder(
                  padding:const EdgeInsets.all(10),
                  gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7,crossAxisSpacing:2.5,mainAxisSpacing:2.5),
                  physics:const NeverScrollableScrollPhysics(),
                  itemCount:49,
                  itemBuilder:(_,i){
                    const p=[true,true,true,false,true,true,true,true,false,true,false,true,false,true,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,true,true,false,true,true,false,true,false,true,false,true,true,true,true,false,true,true,true];
                    return Container(decoration:BoxDecoration(color:p[i]?Colors.white:Colors.transparent,borderRadius:BorderRadius.circular(1.5)));
                  })),
              const SizedBox(height:14),
              Text('Order #${widget.orderId}',style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
              const SizedBox(height:3),
              Text('${r.name} · ${r.location}',style:GoogleFonts.sora(fontSize:11,color:AppColors.gray)),
            ])),
          const SizedBox(height:18),
          // Chips
          Row(children:[
            _chip('🕐', widget.isDelivery?'Delivery':widget.selectedTime, widget.isDelivery?'Delivery':'Pickup'),
            const SizedBox(width:8),
            _chip('💰','Rs $saved','Bachat'),
            const SizedBox(width:8),
            _chip('🌿','1 Bag','Bachaya'),
          ]),
          const SizedBox(height:24),
          SizedBox(width:double.infinity,
            child:ElevatedButton(onPressed:(){},child:const Text('📍 Directions Lein'))),
          const SizedBox(height:10),
          SizedBox(width:double.infinity,
            child:OutlinedButton(
              style:OutlinedButton.styleFrom(foregroundColor:AppColors.greenMid,
                side:const BorderSide(color:AppColors.greenPale,width:1.5),
                padding:const EdgeInsets.symmetric(vertical:14),
                shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
                textStyle:GoogleFonts.sora(fontSize:13,fontWeight:FontWeight.w600)),
              onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const MainScreen()),(_)=>false),
              child:const Text('Home Par Wapis Jao'))),
          const SizedBox(height:30),
        ]))));
  }
  Widget _chip(String ico, String val, String lbl) => Expanded(
    child:Container(padding:const EdgeInsets.symmetric(vertical:14,horizontal:8),
      decoration:cardDecoration(radius:14),
      child:Column(children:[
        Text(ico,style:const TextStyle(fontSize:20)),
        const SizedBox(height:5),
        Text(val,style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.charcoal),textAlign:TextAlign.center),
        const SizedBox(height:2),
        Text(lbl,style:GoogleFonts.sora(fontSize:9,color:AppColors.lightGray)),
      ])));
}
