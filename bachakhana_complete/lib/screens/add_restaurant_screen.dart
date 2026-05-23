import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/app_state.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});
  @override State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _name=TextEditingController(), _addr=TextEditingController(),
        _orig=TextEditingController(), _price=TextEditingController(),
        _bags=TextEditingController(), _time=TextEditingController(),
        _desc=TextEditingController(), _delCharge=TextEditingController(),
        _delTime=TextEditingController();
  String _cat='', _city='Rawalpindi';
  bool _hasDel=false, _loading=false;

  final _cats=[
    {'id':'desi','lbl':'🥘 Desi / Pakistani'},{'id':'fastfood','lbl':'🍕 Fast Food'},
    {'id':'chinese','lbl':'🍜 Chinese'},{'id':'bakery','lbl':'🎂 Bakery'},
    {'id':'cafe','lbl':'☕ Cafe'},{'id':'steaks','lbl':'🥩 Steaks'},
    {'id':'italian','lbl':'🍝 Italian'},
  ];

  @override void dispose() {
    [_name,_addr,_orig,_price,_bags,_time,_desc,_delCharge,_delTime]
      .forEach((c)=>c.dispose());
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty){_show('Restaurant ka naam likhein!');return;}
    if (_cat.isEmpty){_show('Category choose karein!');return;}
    if (_addr.text.trim().isEmpty){_show('Address likhein!');return;}
    final p=int.tryParse(_price.text)??350;
    if (p<=0){_show('Bag price sahi likho.');return;}

    setState(()=>_loading=true);
    final emojis={'desi':'🥘','fastfood':'🍕','chinese':'🍜','bakery':'🎂','cafe':'☕','steaks':'🥩','italian':'🍝'};
    final grads={
      'desi':['#1B4332','#2D6A4F'],'fastfood':['#E76F51','#F4A261'],
      'chinese':['#185FA5','#378ADD'],'bakery':['#633806','#EF9F27'],
      'cafe':['#854F0B','#D97706'],'steaks':['#7F1D1D','#EF4444'],
      'italian':['#1E3A5F','#2563EB'],
    };
    final orig=int.tryParse(_orig.text)??1000;
    final bags=int.tryParse(_bags.text)??3;
    final time=_time.text.isEmpty?'7:00–8:00 PM':_time.text;

    final rest=RestaurantModel(
      firestoreId:'', id:DateTime.now().millisecondsSinceEpoch,
      name:_name.text.trim(), category:_cat,
      emoji:emojis[_cat]??'🍽️',
      gradientHex:List<String>.from(grads[_cat]??['#1B4332','#2D6A4F']),
      location:'${_addr.text.trim()}, $_city', city:_city,
      distance:2.0, rating:4.5, reviewCount:0,
      badge:'🆕 New', badgeType:'blue',
      hasDelivery:_hasDel,
      deliveryCharge:_hasDel?(int.tryParse(_delCharge.text)??100):0,
      deliveryTime:_hasDel?(_delTime.text.isEmpty?'30-40 min':_delTime.text):'',
      bagPrice:p, origPrice:orig, bagsLeft:bags, timer:'Naya',
      slots:[SlotModel(name:'Surprise Bag',avail:bags,times:[time],
        desc:_desc.text.isEmpty?'Aaj ka surplus khana.':_desc.text,
        origPrice:orig,bagPrice:p)],
      tags:['${emojis[_cat]} $_cat','🌿 Naya'],
      reviews:[const ReviewModel(user:'BachaKhana',stars:'⭐⭐⭐⭐⭐',text:'Naya restaurant!')],
      ownerId:context.read<AppState>().currentUser?.uid??'',
      isApproved:false, // Admin approval pending
    );

    await context.read<AppState>().addRestaurant(rest);
    if (!mounted) return;
    setState(()=>_loading=false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content:Text('✅ Restaurant add ho gaya! Admin approval ke baad show hoga.'),
      backgroundColor:AppColors.greenMid));
    [_name,_addr,_orig,_price,_bags,_time,_desc,_delCharge,_delTime].forEach((c)=>c.clear());
    setState(()=>_cat=''; _hasDel=false);
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content:Text(m), backgroundColor:AppColors.saffron));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(title:const Text('Restaurant Add Karein'), automaticallyImplyLeading:false),
    body: SingleChildScrollView(padding:const EdgeInsets.all(16),
      child: Column(children:[
        _card('Basic Info',[
          _f('Restaurant ka Naam *',_name,'e.g. Savour Foods'),
          const SizedBox(height:12),
          _lbl('Category *'), const SizedBox(height:6),
          DropdownButtonFormField<String>(value:_cat.isEmpty?null:_cat,
            decoration:const InputDecoration(),
            hint:Text('Choose karein',style:GoogleFonts.sora(fontSize:13,color:AppColors.lightGray)),
            items:_cats.map((c)=>DropdownMenuItem(value:c['id'],child:Text(c['lbl']!,style:GoogleFonts.sora(fontSize:13)))).toList(),
            onChanged:(v)=>setState(()=>_cat=v??'')),
          const SizedBox(height:12),
          _f('Address *',_addr,'e.g. F-7 Markaz, Islamabad'),
          const SizedBox(height:12),
          _lbl('Shahar'), const SizedBox(height:6),
          DropdownButtonFormField<String>(value:_city,decoration:const InputDecoration(),
            items:['Rawalpindi','Islamabad'].map((c)=>DropdownMenuItem(value:c,child:Text(c,style:GoogleFonts.sora(fontSize:13)))).toList(),
            onChanged:(v)=>setState(()=>_city=v!)),
        ]),
        const SizedBox(height:14),
        _card('Surprise Bag Details',[
          Row(children:[
            Expanded(child:_f('Original Price (Rs)',_orig,'2000',num:true)),
            const SizedBox(width:10),
            Expanded(child:_f('Bag Price (Rs)',_price,'650',num:true)),
          ]),
          const SizedBox(height:12),
          Row(children:[
            Expanded(child:_f('Bags Available',_bags,'3',num:true)),
            const SizedBox(width:10),
            Expanded(child:_f('Pickup Time',_time,'7–8 PM')),
          ]),
          const SizedBox(height:12),
          _lbl('Bag Description'), const SizedBox(height:6),
          TextField(controller:_desc, maxLines:3, style:GoogleFonts.sora(fontSize:13),
            decoration:const InputDecoration(hintText:'Kya milega is bag mein...')),
        ]),
        const SizedBox(height:14),
        _card('Delivery Options',[
          Row(children:[
            Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Home Delivery?',style:GoogleFonts.sora(fontSize:13,fontWeight:FontWeight.w600,color:AppColors.charcoal)),
              Text('Restaurant delivery deta hai?',style:GoogleFonts.sora(fontSize:10,color:AppColors.lightGray)),
            ]),
            const Spacer(),
            Switch(value:_hasDel,activeColor:AppColors.greenMid,onChanged:(v)=>setState(()=>_hasDel=v)),
          ]),
          if (_hasDel)...[
            const SizedBox(height:12),
            Container(padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:AppColors.greenPaler,borderRadius:BorderRadius.circular(12)),
              child:Row(children:[
                Expanded(child:_f('Charge (Rs)',_delCharge,'100',num:true)),
                const SizedBox(width:10),
                Expanded(child:_f('Time',_delTime,'30-40 min')),
              ])),
          ],
        ]),
        const SizedBox(height:20),
        SizedBox(width:double.infinity,
          child:ElevatedButton(
            onPressed:_loading?null:_submit,
            style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:16)),
            child:_loading
              ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2))
              : const Text('✅ Restaurant Add Karein'))),
        const SizedBox(height:30),
      ])));

  Widget _card(String title, List<Widget> children) => Container(
    width:double.infinity, decoration:cardDecoration(radius:18), padding:const EdgeInsets.all(16),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title.toUpperCase(),style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.gray,letterSpacing:0.06)),
      const SizedBox(height:14),
      ...children,
    ]));

  Widget _f(String lbl, TextEditingController c, String hint, {bool num=false}) =>
    Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _lbl(lbl), const SizedBox(height:6),
      TextField(controller:c,keyboardType:num?TextInputType.number:TextInputType.text,
        style:GoogleFonts.sora(fontSize:13),decoration:InputDecoration(hintText:hint)),
    ]);

  Widget _lbl(String t) => Text(t,style:GoogleFonts.sora(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.charcoal));
}
