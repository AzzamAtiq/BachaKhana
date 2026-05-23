// detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/app_state.dart';
import 'checkout_screen.dart';

class DetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const DetailScreen({super.key, required this.restaurant});
  @override State<DetailScreen> createState() => _DetailScreenState();
}
class _DetailScreenState extends State<DetailScreen> {
  String? _selTime;
  RestaurantModel get r => widget.restaurant;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final isFav = st.isFavorite(r.firestoreId);
    return Scaffold(backgroundColor: AppColors.cream,
      body: CustomScrollView(slivers:[
        SliverAppBar(expandedHeight:220, pinned:true,
          backgroundColor: r.gradientColors.first,
          leading: GestureDetector(onTap:()=>Navigator.pop(context),
            child: Container(margin:const EdgeInsets.all(10),
              decoration: BoxDecoration(color:Colors.white.withOpacity(0.85),borderRadius:BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back,color:AppColors.charcoal,size:18))),
          actions:[
            GestureDetector(onTap:()=>st.toggleFavorite(r.firestoreId),
              child: Container(margin:const EdgeInsets.all(10),
                decoration: BoxDecoration(color:Colors.white.withOpacity(0.85),borderRadius:BorderRadius.circular(12)),
                child: Padding(padding:const EdgeInsets.all(7),
                  child: Text(isFav?'❤️':'🤍',style:const TextStyle(fontSize:16))))),
          ],
          flexibleSpace: FlexibleSpaceBar(background: Container(
            decoration: BoxDecoration(gradient:LinearGradient(colors:r.gradientColors)),
            child: Center(child:Text(r.emoji,style:const TextStyle(fontSize:80)))))),
        SliverToBoxAdapter(child: Column(children:[
          // Info card
          Container(margin:const EdgeInsets.fromLTRB(14,-24,14,14),
            decoration: shadowDecoration(radius:22), padding:const EdgeInsets.all(16),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(r.name,style:GoogleFonts.sora(fontSize:19,fontWeight:FontWeight.w800,color:AppColors.charcoal)),
              const SizedBox(height:6),
              Wrap(spacing:14,children:[
                Text('📍 ${r.location}',style:GoogleFonts.sora(fontSize:11,color:AppColors.gray)),
                Text('⭐ ${r.rating} (${r.reviewCount})',style:GoogleFonts.sora(fontSize:11,color:AppColors.gray)),
              ]),
              const SizedBox(height:12),
              Wrap(spacing:6,runSpacing:6,children:[
                for (final t in r.tags) _tag(t,AppColors.greenPale,AppColors.greenMid),
                if (r.hasDelivery) _tag('🛵 Delivery',AppColors.bluePale,AppColors.blue),
              ]),
            ])),
          // Delivery strip
          Container(margin:const EdgeInsets.fromLTRB(14,0,14,14),
            padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
            decoration: BoxDecoration(color:r.hasDelivery?AppColors.bluePale:AppColors.redPale,borderRadius:BorderRadius.circular(14)),
            child: Row(children:[
              Text(r.hasDelivery?'🛵':'🚶',style:const TextStyle(fontSize:20)),
              const SizedBox(width:10),
              Expanded(child: Text(r.hasDelivery?'Home Delivery — Rs ${r.deliveryCharge} · ${r.deliveryTime}':'Sirf Pickup',
                style:GoogleFonts.sora(fontSize:12,color:r.hasDelivery?AppColors.blue:AppColors.red,fontWeight:FontWeight.w500))),
            ])),
          // Slots
          Padding(padding:const EdgeInsets.symmetric(horizontal:14),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('📦 Surprise Bags',style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
              const SizedBox(height:12),
              for (final s in r.slots) _slot(s),
            ])),
          // Reviews
          Padding(padding:const EdgeInsets.fromLTRB(14,14,14,0),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('⭐ Reviews',style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
              const SizedBox(height:12),
              for (final rv in r.reviews) Container(margin:const EdgeInsets.only(bottom:10),
                decoration:cardDecoration(radius:14), padding:const EdgeInsets.all(14),
                child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Text(rv.user,style:GoogleFonts.sora(fontSize:12,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
                    const Spacer(),
                    Text(rv.stars,style:const TextStyle(fontSize:11)),
                  ]),
                  const SizedBox(height:6),
                  Text(rv.text,style:GoogleFonts.sora(fontSize:11,color:AppColors.gray,height:1.6)),
                ])),
            ])),
          const SizedBox(height:32),
        ])),
      ]));
  }

  Widget _slot(SlotModel s) {
    final sold=s.avail==0; final low=s.avail>0&&s.avail<=2;
    return Container(margin:const EdgeInsets.only(bottom:12),
      decoration:cardDecoration(radius:16), padding:const EdgeInsets.all(14),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Text(s.name,style:GoogleFonts.sora(fontSize:13,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
          const Spacer(),
          Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:3),
            decoration:BoxDecoration(color:sold?AppColors.redPale:low?const Color(0xFFFEF9C3):AppColors.greenPale,borderRadius:BorderRadius.circular(8)),
            child:Text(sold?'Sold Out':low?'Sirf ${s.avail} baki':'${s.avail} available',
              style:GoogleFonts.sora(fontSize:9,fontWeight:FontWeight.w700,color:sold?AppColors.red:low?const Color(0xFF92400E):AppColors.greenMid))),
        ]),
        const SizedBox(height:8),
        Text(s.desc,style:GoogleFonts.sora(fontSize:11,color:AppColors.gray,height:1.6)),
        const SizedBox(height:10),
        Wrap(spacing:6,runSpacing:6,children:s.times.map((t){
          final on=_selTime==t;
          return GestureDetector(onTap:sold?null:()=>setState(()=>_selTime=t),
            child:AnimatedContainer(duration:const Duration(milliseconds:150),
              padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),
              decoration:BoxDecoration(color:on?AppColors.green:AppColors.bg,borderRadius:BorderRadius.circular(9),
                border:Border.all(color:on?AppColors.green:AppColors.border,width:1.5)),
              child:Text(t,style:GoogleFonts.sora(fontSize:10,fontWeight:FontWeight.w600,color:on?Colors.white:AppColors.charcoal))));
        }).toList()),
        const SizedBox(height:12),
        Row(children:[
          Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Rs ${s.origPrice}',style:GoogleFonts.sora(fontSize:10,color:AppColors.lightGray,decoration:TextDecoration.lineThrough)),
            Text('Rs ${s.bagPrice}',style:GoogleFonts.sora(fontSize:22,fontWeight:FontWeight.w800,color:AppColors.greenMid)),
            Text('Rs ${s.origPrice-s.bagPrice} ki bachat!',style:GoogleFonts.sora(fontSize:10,fontWeight:FontWeight.w700,color:AppColors.saffron)),
          ]),
          const Spacer(),
          ElevatedButton(onPressed:sold?null:()=>_checkout(s),
            style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(horizontal:20,vertical:12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
            child:Text(sold?'Sold Out':'Reserve Karein →')),
        ]),
      ]));
  }

  Widget _tag(String t, Color bg, Color fg) => Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
    decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(8)),
    child:Text(t,style:GoogleFonts.sora(fontSize:10,fontWeight:FontWeight.w600,color:fg)));

  void _checkout(SlotModel s) => Navigator.push(context, MaterialPageRoute(
    builder:(_)=>CheckoutScreen(restaurant:r,slot:s,selectedTime:_selTime??s.times.first)));
}
