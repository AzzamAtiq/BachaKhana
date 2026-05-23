// main_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'add_restaurant_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  final _screens = const [HomeScreen(), MapScreen(), AddRestaurantScreen(), OrdersScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _screens),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.06),blurRadius:12,offset:const Offset(0,-4))]),
      child: SafeArea(top: false, child: SizedBox(height: 60,
        child: Row(children: [
          _ni(0, Icons.home_rounded, 'Home'),
          _ni(1, Icons.map_outlined, 'Map'),
          _addBtn(),
          _ni(3, Icons.shopping_bag_outlined, 'Orders'),
          _ni(4, Icons.person_outline, 'Profile'),
        ]))),
    ),
  );

  Widget _ni(int i, IconData ico, String lbl) => Expanded(
    child: GestureDetector(onTap: ()=>setState(()=>_idx=i),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ico, size:22, color: _idx==i ? AppColors.greenMid : AppColors.lightGray),
        const SizedBox(height:3),
        Text(lbl, style: GoogleFonts.sora(fontSize:9, fontWeight:FontWeight.w500,
          color: _idx==i ? AppColors.greenMid : AppColors.lightGray)),
      ])));

  Widget _addBtn() => Expanded(child: GestureDetector(onTap:()=>setState(()=>_idx=2),
    child: Center(child: Container(width:48, height:48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors:[AppColors.greenMid, AppColors.green],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow:[BoxShadow(color:AppColors.green.withOpacity(0.3),blurRadius:10,offset:const Offset(0,4))]),
      child: const Icon(Icons.add, color:Colors.white, size:24)))));
}
