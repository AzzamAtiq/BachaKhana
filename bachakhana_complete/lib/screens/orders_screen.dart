import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Meri Orders 🛍️'), automaticallyImplyLeading: false),
      body: Column(children: [
        // Stats bar
        Container(color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(children: [
            _stat('${st.orders.length}', 'Kul Orders'),
            Container(height: 40, width: 1, margin: const EdgeInsets.only(top: 16), color: AppColors.border),
            _stat('Rs ${st.totalSaved}', 'Kul Bachat'),
            Container(height: 40, width: 1, margin: const EdgeInsets.only(top: 16), color: AppColors.border),
            _stat('${st.orders.length}', 'Bags'),
          ])),
        Expanded(child: st.orders.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🛍️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              Text('Abhi koi order nahi', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(height: 6),
              Text('Koi restaurant choose karo aur\napna pehla Surprise Bag reserve karo!',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 12, color: AppColors.gray)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: st.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final o = st.orders[i];
                return Container(decoration: cardDecoration(radius: 16),
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(width: 50, height: 50,
                      decoration: BoxDecoration(color: AppColors.greenPale, borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(o.emoji, style: const TextStyle(fontSize: 24)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.restaurantName, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                      Text('${o.bagName} · Rs ${o.price}', style: GoogleFonts.sora(fontSize: 11, color: AppColors.gray)),
                      Text(o.isDelivery ? '🛵 Delivery' : '🕐 Pickup: ${o.pickupTime ?? ''}',
                        style: GoogleFonts.sora(fontSize: 10, color: AppColors.lightGray)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: o.status == 'confirmed' ? AppColors.greenPale : AppColors.redPale,
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(o.status == 'confirmed' ? 'Confirmed' : o.status,
                          style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700,
                            color: o.status == 'confirmed' ? AppColors.greenMid : AppColors.red))),
                      const SizedBox(height: 4),
                      Text('Rs ${o.saved} bacha', style: GoogleFonts.sora(fontSize: 10, color: AppColors.saffron, fontWeight: FontWeight.w600)),
                    ]),
                  ]));
              })),
      ]),
    );
  }

  Widget _stat(String val, String lbl) => Expanded(
    child: Padding(padding: const EdgeInsets.only(top: 16),
      child: Column(children: [
        Text(val, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.greenMid)),
        const SizedBox(height: 2),
        Text(lbl, style: GoogleFonts.sora(fontSize: 10, color: AppColors.lightGray)),
      ])));
}
