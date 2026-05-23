import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/app_state.dart';
import '../services/payment_service.dart';
import '../services/notification_service.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  final SlotModel slot;
  final String selectedTime;

  const CheckoutScreen({super.key,
    required this.restaurant, required this.slot, required this.selectedTime});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryMode  = 'pickup';
  int    _selectedPay   = 0; // 0=Jazz 1=Easy 2=Card
  bool   _paying        = false;
  String? _payError;

  RestaurantModel get r    => widget.restaurant;
  SlotModel       get slot => widget.slot;

  int get total => _deliveryMode == 'delivery' && r.hasDelivery
    ? slot.bagPrice + r.deliveryCharge : slot.bagPrice;

  String get paymentMethod => _selectedPay == 0 ? 'jazzcash'
    : _selectedPay == 1 ? 'easypaisa' : 'card';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ── Order Summary ──
          _buildSummary(),
          const SizedBox(height: 14),

          // ── Error ──
          if (_payError != null) ...[
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.redPale,
                borderRadius: BorderRadius.circular(12)),
              child: Text('⚠️ $_payError',
                style: GoogleFonts.sora(fontSize: 12, color: AppColors.red))),
            const SizedBox(height: 14),
          ],

          // ── Delivery Toggle ──
          if (r.hasDelivery) ...[_buildDeliveryToggle(), const SizedBox(height: 14)],

          // ── Pickup/Delivery Info ──
          _buildPickupCard(), const SizedBox(height: 14),

          // ── Payment ──
          _buildPayment(), const SizedBox(height: 14),

          // ── Savings Strip ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.green, AppColors.greenMid]),
              borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('🌿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text('Aap Rs ${slot.origPrice - slot.bagPrice} ki bachat kar rahe hain! 🎉',
                style: GoogleFonts.sora(fontSize: 12,
                  fontWeight: FontWeight.w600, color: Colors.white)),
            ])),
          const SizedBox(height: 16),

          // ── Pay Button ──
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _paying ? null : () => _pay(context, user),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 17)),
              child: _paying
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(_getPayBtnLabel(),
                      style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
            )),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  String _getPayBtnLabel() {
    if (_selectedPay == 0) return '💳 JazzCash se Pay — Rs $total';
    if (_selectedPay == 1) return '📱 EasyPaisa se Pay — Rs $total';
    return '💳 Card se Pay — Rs $total';
  }

  Future<void> _pay(BuildContext ctx, UserModel? user) async {
    setState(() { _paying = true; _payError = null; });

    PaymentResult? result;
    String? transactionId;

    try {
      if (_selectedPay == 0) {
        // ── JazzCash ──
        result = await JazzCashService.launchPayment(
          context: ctx,
          amountRs: total,
          customerPhone: user?.phone ?? '03001234567',
          orderId: 'BK${DateTime.now().millisecondsSinceEpoch}',
          restaurantName: r.name,
        );
        if (!result.success) {
          setState(() {
            _payError = 'JazzCash payment fail hua. Dobara try karein.';
            _paying = false;
          });
          return;
        }
        transactionId = result.txnRef;

      } else if (_selectedPay == 1) {
        // ── EasyPaisa ── (similar flow)
        result = PaymentResult(success: true,
          txnRef: 'EP${DateTime.now().millisecondsSinceEpoch}');
        transactionId = result.txnRef;

      } else {
        // ── Card — simulate for now ──
        await Future.delayed(const Duration(seconds: 2));
        transactionId = 'CARD${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      setState(() { _payError = 'Payment mein masla hua. Dobara try karein.'; _paying = false; });
      return;
    }

    // ── Place Order in Firestore ──
    final state = ctx.read<AppState>();
    final orderId = await state.placeOrder(
      restaurant: r, slot: slot, selectedTime: widget.selectedTime,
      isDelivery: _deliveryMode == 'delivery',
      paymentMethod: paymentMethod, transactionId: transactionId,
    );

    if (!mounted) return;

    if (orderId == null) {
      setState(() { _payError = state.error ?? 'Order place nahi ho saki.'; _paying = false; });
      return;
    }

    // ── Show notification ──
    await NotificationService.showOrderConfirmed(r.name, orderId);

    setState(() => _paying = false);

    Navigator.pushReplacement(ctx, MaterialPageRoute(
      builder: (_) => SuccessScreen(
        orderId: orderId, restaurant: r, slot: slot,
        selectedTime: widget.selectedTime, isDelivery: _deliveryMode == 'delivery',
      )));
  }

  Widget _buildSummary() => Container(
    decoration: cardDecoration(radius: 18),
    child: Column(children: [
      Padding(padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.greenPale,
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(r.emoji,
              style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: GoogleFonts.sora(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            Text('Surprise Bag × 1', style: GoogleFonts.sora(
              fontSize: 11, color: AppColors.gray)),
          ]),
        ])),
      Divider(height: 1, color: AppColors.border),
      _sumRow('Original Qeemat', 'Rs ${slot.origPrice}', false),
      _sumRow('Bag Qeemat', 'Rs ${slot.bagPrice}', false),
      if (_deliveryMode == 'delivery' && r.hasDelivery)
        _sumRow('Delivery Charge', 'Rs ${r.deliveryCharge}', false),
      Divider(height: 1, color: AppColors.border),
      _sumRow('Kul Total', 'Rs $total', true),
    ]));

  Widget _sumRow(String lbl, String val, bool bold) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Text(lbl, style: GoogleFonts.sora(fontSize: bold ? 13 : 12,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: bold ? AppColors.charcoal : AppColors.gray)),
      const Spacer(),
      Text(val, style: GoogleFonts.sora(
        fontSize: bold ? 16 : 12,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        color: bold ? AppColors.greenMid : AppColors.charcoal)),
    ]));

  Widget _buildDeliveryToggle() => Container(
    decoration: cardDecoration(radius: 18),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Kaise Lena Hai?', style: GoogleFonts.sora(fontSize: 11,
        fontWeight: FontWeight.w700, color: AppColors.gray, letterSpacing: 0.05)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _delOpt('pickup', '🚶', 'Pickup', 'Free')),
        const SizedBox(width: 10),
        Expanded(child: _delOpt('delivery', '🛵', 'Delivery', 'Rs ${r.deliveryCharge}')),
      ]),
    ]));

  Widget _delOpt(String mode, String ico, String name, String sub) =>
    GestureDetector(
      onTap: () => setState(() => _deliveryMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _deliveryMode == mode ? AppColors.greenPaler : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _deliveryMode == mode ? AppColors.greenMid : AppColors.border,
            width: 2)),
        child: Column(children: [
          Text(ico, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(name, style: GoogleFonts.sora(fontSize: 11,
            fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          Text(sub, style: GoogleFonts.sora(fontSize: 9, color: AppColors.gray)),
        ])));

  Widget _buildPickupCard() => Container(
    decoration: cardDecoration(radius: 18),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_deliveryMode == 'delivery' ? 'Delivery Address' : 'Pickup Ki Jaga',
        style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.gray, letterSpacing: 0.05)),
      const SizedBox(height: 12),
      Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.greenPale,
            borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(
            _deliveryMode == 'delivery' ? '🏠' : '🕐',
            style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_deliveryMode == 'delivery' ? 'Aap ka ghar / office'
              : 'Aaj — ${widget.selectedTime}',
            style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.charcoal)),
          Text(_deliveryMode == 'delivery'
              ? 'Estimated: ${r.deliveryTime}'
              : '📍 ${r.name}, ${r.location}',
            style: GoogleFonts.sora(fontSize: 11, color: AppColors.gray)),
        ]),
      ]),
    ]));

  Widget _buildPayment() => Container(
    decoration: cardDecoration(radius: 18),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Payment ka Tarika', style: GoogleFonts.sora(fontSize: 11,
        fontWeight: FontWeight.w700, color: AppColors.gray, letterSpacing: 0.05)),
      const SizedBox(height: 12),
      _payOpt(0, 'Jazz', const Color(0xFFE63329), 'JazzCash'),
      const SizedBox(height: 8),
      _payOpt(1, 'Easy', const Color(0xFF7B2D8B), 'EasyPaisa'),
      const SizedBox(height: 8),
      _payOpt(2, '💳', AppColors.charcoal, 'Debit / Credit Card'),
    ]));

  Widget _payOpt(int idx, String logo, Color logoBg, String name) =>
    GestureDetector(
      onTap: () => setState(() => _selectedPay = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedPay == idx ? AppColors.greenPaler : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPay == idx ? AppColors.greenMid : AppColors.border,
            width: 1.5)),
        child: Row(children: [
          Container(width: 36, height: 26,
            decoration: BoxDecoration(color: logoBg,
              borderRadius: BorderRadius.circular(7)),
            child: Center(child: Text(logo, style: GoogleFonts.sora(
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.sora(fontSize: 13,
            fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const Spacer(),
          Container(width: 16, height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(
                color: _selectedPay == idx ? AppColors.greenMid : AppColors.lightGray,
                width: 2)),
            child: _selectedPay == idx
              ? Center(child: Container(width: 8, height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle,
                    color: AppColors.greenMid))) : null),
        ])));
}
