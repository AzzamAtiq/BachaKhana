import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;
  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: cardDecoration(radius: 20),
        child: Column(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(height: 120,
              decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradientColors)),
              child: Stack(children: [
                Center(child: Text(r.emoji, style: const TextStyle(fontSize: 56))),
                Positioned(top: 10, left: 10, child: _badge(r.badge, r.badgeType)),
                Positioned(top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: Text('⏰ ${r.timer}', style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)))),
              ]))),
          Padding(padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(r.name, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal))),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text('${r.rating} (${r.reviewCount})', style: GoogleFonts.sora(fontSize: 10, color: AppColors.gray)),
                ]),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.lightGray),
                const SizedBox(width: 2),
                Expanded(child: Text('${r.location} · ${r.distance}km',
                  style: GoogleFonts.sora(fontSize: 10, color: AppColors.lightGray),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 5, runSpacing: 4, children: [
                if (r.hasDelivery) _tag('🛵 Delivery', AppColors.bluePale, AppColors.blue),
                for (final t in r.tags.take(1))
                  _tag(t, AppColors.greenPaler, AppColors.greenMid),
              ]),
              const SizedBox(height: 10),
              Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              Row(children: [
                Text('Rs ${r.bagPrice}', style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.greenMid)),
                const SizedBox(width: 6),
                Text('Rs ${r.origPrice}', style: GoogleFonts.sora(fontSize: 10, color: AppColors.lightGray, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 5),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.saffronPale, borderRadius: BorderRadius.circular(6)),
                  child: Text('-${r.discount}%', style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.saffron))),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${r.bagsLeft} 📦', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700,
                    color: r.bagsLeft <= 2 ? AppColors.saffron : AppColors.charcoal)),
                  Text('baki', style: GoogleFonts.sora(fontSize: 9, color: AppColors.lightGray)),
                ]),
              ]),
            ])),
        ])));
  }

  Widget _badge(String text, String type) {
    Color bg; switch(type){case 'hot':bg=AppColors.saffron;break;case 'green':bg=AppColors.greenMid;break;case 'gold':bg=AppColors.gold;break;default:bg=AppColors.blue;}
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)));
  }

  Widget _tag(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
    child: Text(text, style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.w600, color: fg)));
}
