import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/restaurant_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final _sc = TextEditingController();
  final _cats = [
    {'id':'all','lbl':'Sab','e':'🍽️'},{'id':'desi','lbl':'Desi','e':'🥘'},
    {'id':'fastfood','lbl':'Fast Food','e':'🍕'},{'id':'chinese','lbl':'Chinese','e':'🍜'},
    {'id':'cafe','lbl':'Cafe','e':'☕'},{'id':'steaks','lbl':'Steaks','e':'🥩'},
    {'id':'bakery','lbl':'Bakery','e':'🎂'},{'id':'italian','lbl':'Italian','e':'🍝'},
  ];
  @override void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers:[
        SliverToBoxAdapter(child: _header(st)),
        SliverToBoxAdapter(child: _search(st)),
        SliverToBoxAdapter(child: _banner()),
        SliverToBoxAdapter(child: _cats_(st)),
        if (st.featuredRestaurants.isNotEmpty) ...[
          SliverToBoxAdapter(child: _secHdr('⚡ Jaldi Khatam Ho Rahay', null)),
          SliverToBoxAdapter(child: _featured(st)),
        ],
        SliverToBoxAdapter(child: _secHdr('🏪 Sab Restaurants','${st.filteredRestaurants.length} mili')),
        if (st.isLoading)
          const SliverToBoxAdapter(child: Center(
            child: Padding(padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.greenMid))))
        else if (st.filteredRestaurants.isEmpty)
          SliverToBoxAdapter(child: _empty())
        else
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(padding: const EdgeInsets.fromLTRB(16,0,16,12),
              child: RestaurantCard(restaurant: st.filteredRestaurants[i],
                onTap: () => _open(st.filteredRestaurants[i]))),
            childCount: st.filteredRestaurants.length)),
        const SliverToBoxAdapter(child: SizedBox(height:24)),
      ]));
  }

  Widget _header(AppState st) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [AppColors.green, AppColors.greenMid],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: SafeArea(bottom:false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20,12,20,24),
      child: Column(children:[
        Row(children:[
          GestureDetector(onTap:()=>_cityPicker(st),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Text('📍 Aap ki location', style:GoogleFonts.sora(fontSize:10,color:Colors.white54)),
              const SizedBox(height:2),
              Row(children:[
                Text(st.selectedCity=='Sab'?'Rawalpindi / Islamabad':st.selectedCity,
                  style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:Colors.white)),
                const SizedBox(width:4),
                const Icon(Icons.keyboard_arrow_down,color:Colors.white70,size:18),
              ]),
            ])),
          const Spacer(),
          Container(width:36,height:36,
            decoration: BoxDecoration(color:Colors.white.withOpacity(0.12),borderRadius:BorderRadius.circular(12),border:Border.all(color:Colors.white.withOpacity(0.1))),
            child: const Icon(Icons.notifications_outlined,color:Colors.white,size:18)),
        ]),
        const SizedBox(height:16),
        Text('Aaj kya bachayein? 🌿', style:GoogleFonts.sora(fontSize:20,fontWeight:FontWeight.w800,color:Colors.white,letterSpacing:-0.5)),
        const SizedBox(height:4),
        Text('${st.allRestaurants.length} restaurants mein surplus food available hai',
          style:GoogleFonts.sora(fontSize:11,color:Colors.white54)),
      ]))));

  Widget _search(AppState st) => Container(
    margin:const EdgeInsets.fromLTRB(16,12,16,0),
    decoration: shadowDecoration(radius:16),
    child: TextField(controller:_sc, onChanged:st.setSearch, style:GoogleFonts.sora(fontSize:13),
      decoration: InputDecoration(hintText:'Restaurant ya khana dhondho...',
        border: OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:AppColors.greenLight,width:1.5)),
        filled:true, fillColor:Colors.white,
        prefixIcon: const Icon(Icons.search,color:AppColors.lightGray,size:20),
        suffixIcon: Container(margin:const EdgeInsets.all(8),
          decoration:BoxDecoration(color:AppColors.green,borderRadius:BorderRadius.circular(10)),
          child:const Icon(Icons.tune,color:Colors.white,size:16)),
        contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:14))));

  Widget _banner() => Container(
    margin:const EdgeInsets.fromLTRB(16,14,16,0),
    decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.saffron,AppColors.saffronLight]),borderRadius:BorderRadius.circular(18)),
    padding:const EdgeInsets.all(16),
    child:Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Aaj sirf Rs 200 mein! 🔥', style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:Colors.white)),
        const SizedBox(height:4),
        Text('Savour Foods ka Surprise Bag\nsirf aaj raat 9 baje tak',
          style:GoogleFonts.sora(fontSize:10,color:Colors.white70,height:1.5)),
      ])),
      Container(padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),
        decoration:BoxDecoration(color:Colors.white.withOpacity(0.2),borderRadius:BorderRadius.circular(12),border:Border.all(color:Colors.white.withOpacity(0.25))),
        child:Column(children:[
          Text('3', style:GoogleFonts.sora(fontSize:20,fontWeight:FontWeight.w800,color:Colors.white)),
          Text('Bags baki', style:GoogleFonts.sora(fontSize:8,color:Colors.white70)),
        ])),
    ]));

  Widget _cats_(AppState st) => SizedBox(height:80,
    child: ListView.separated(scrollDirection:Axis.horizontal,
      padding:const EdgeInsets.fromLTRB(16,14,16,0),
      itemCount:_cats.length,
      separatorBuilder:(_,__)=>const SizedBox(width:8),
      itemBuilder:(_, i) {
        final c=_cats[i]; final on=st.selectedCategory==c['id'];
        return GestureDetector(onTap:()=>st.setCategory(c['id']!),
          child:AnimatedContainer(duration:const Duration(milliseconds:200),
            padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
            decoration:BoxDecoration(color:on?AppColors.green:Colors.white,
              borderRadius:BorderRadius.circular(16),
              border:Border.all(color:on?AppColors.green:AppColors.border,width:1.5)),
            child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
              Text(c['e']!, style:const TextStyle(fontSize:20)),
              const SizedBox(height:4),
              Text(c['lbl']!, style:GoogleFonts.sora(fontSize:9,fontWeight:FontWeight.w600,color:on?Colors.white:AppColors.gray)),
            ])));
      }));

  Widget _featured(AppState st) => SizedBox(height:200,
    child: ListView.separated(scrollDirection:Axis.horizontal,
      padding:const EdgeInsets.fromLTRB(16,0,16,14),
      itemCount:st.featuredRestaurants.take(5).length,
      separatorBuilder:(_,__)=>const SizedBox(width:10),
      itemBuilder:(_, i) {
        final r=st.featuredRestaurants[i];
        return GestureDetector(onTap:()=>_open(r),
          child:Container(width:160, decoration:cardDecoration(radius:16),
            child:Column(children:[
              ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(16)),
                child:Container(height:100,
                  decoration:BoxDecoration(gradient:LinearGradient(colors:r.gradientColors)),
                  child:Stack(children:[
                    Center(child:Text(r.emoji,style:const TextStyle(fontSize:42))),
                    Positioned(top:8,left:8,child:_badge(r.badge,r.badgeType)),
                  ]))),
              Padding(padding:const EdgeInsets.all(10),
                child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(r.name,style:GoogleFonts.sora(fontSize:12,fontWeight:FontWeight.w700,color:AppColors.charcoal),maxLines:1,overflow:TextOverflow.ellipsis),
                  const SizedBox(height:2),
                  Text('📍 ${r.distance}km',style:GoogleFonts.sora(fontSize:10,color:AppColors.lightGray)),
                  const SizedBox(height:8),
                  Row(children:[
                    Text('Rs ${r.bagPrice}',style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w800,color:AppColors.greenMid)),
                    const SizedBox(width:4),
                    Text('Rs ${r.origPrice}',style:GoogleFonts.sora(fontSize:10,color:AppColors.lightGray,decoration:TextDecoration.lineThrough)),
                  ]),
                ])),
            ])));
      }));

  Widget _secHdr(String title, String? sub) => Padding(
    padding:const EdgeInsets.fromLTRB(16,16,16,10),
    child:Row(children:[
      Text(title,style:GoogleFonts.sora(fontSize:14,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
      const Spacer(),
      if (sub!=null) Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
        decoration:BoxDecoration(color:AppColors.greenPaler,borderRadius:BorderRadius.circular(8)),
        child:Text(sub,style:GoogleFonts.sora(fontSize:10,fontWeight:FontWeight.w600,color:AppColors.greenMid))),
    ]));

  Widget _empty() => Padding(padding:const EdgeInsets.all(40),
    child:Center(child:Column(children:[
      const Text('🔍',style:TextStyle(fontSize:52)),
      const SizedBox(height:14),
      Text('Koi restaurant nahi mila',style:GoogleFonts.sora(fontSize:15,fontWeight:FontWeight.w700,color:AppColors.charcoal)),
      const SizedBox(height:6),
      Text('Search ya filter change karein',style:GoogleFonts.sora(fontSize:12,color:AppColors.gray)),
    ])));

  Widget _badge(String text, String type) {
    Color bg; switch(type){case 'hot':bg=AppColors.saffron;break;case 'green':bg=AppColors.greenMid;break;case 'gold':bg=AppColors.gold;break;default:bg=AppColors.blue;}
    return Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:4),
      decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(20)),
      child:Text(text,style:GoogleFonts.sora(fontSize:9,fontWeight:FontWeight.w700,color:Colors.white)));
  }

  void _open(RestaurantModel r) => Navigator.push(context, MaterialPageRoute(builder:(_)=>DetailScreen(restaurant:r)));
  void _cityPicker(AppState st) => showModalBottomSheet(context:context,
    builder:(_)=>Container(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text('Shahar Choose Karein',style:GoogleFonts.sora(fontSize:16,fontWeight:FontWeight.w700)),
      const SizedBox(height:16),
      for (final c in ['Sab','Rawalpindi','Islamabad'])
        ListTile(title:Text(c,style:GoogleFonts.sora(fontSize:14)),
          trailing:st.selectedCity==c?const Icon(Icons.check,color:AppColors.greenMid):null,
          onTap:(){st.setCity(c);Navigator.pop(context);}),
    ])));
}
