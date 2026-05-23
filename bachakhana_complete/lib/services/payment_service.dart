import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// JazzCash Mobile Account Payment Integration
/// Docs: https://sandbox.jazzcash.com.pk/documentation
///
/// TEST CREDENTIALS (Sandbox):
///   Merchant ID:   MC12345
///   Password:      abcd1234
///   Integrity Salt: s3cr3t_s4lt
///
/// LIVE CREDENTIALS: JazzCash partner portal se milenge

class JazzCashService {
  // ── Sandbox (testing) ──
  static const String _sandboxMerchantId = 'MC12345';
  static const String _sandboxPassword   = 'abcd1234';
  static const String _sandboxSalt       = 's3cr3t_s4lt';
  static const String _sandboxUrl        =
    'https://sandbox.jazzcash.com.pk/CustomerPortal/transactionmanagement/merchantform/';

  // ── Live (production) — JazzCash se milega ──
  static const String _liveMerchantId = 'YOUR_MERCHANT_ID';
  static const String _livePassword   = 'YOUR_PASSWORD';
  static const String _liveSalt       = 'YOUR_INTEGRITY_SALT';
  static const String _liveUrl        =
    'https://payments.jazzcash.com.pk/CustomerPortal/transactionmanagement/merchantform/';

  // Toggle: true = sandbox testing, false = live
  static const bool isSandbox = true;

  static String get merchantId => isSandbox ? _sandboxMerchantId : _liveMerchantId;
  static String get password   => isSandbox ? _sandboxPassword   : _livePassword;
  static String get salt       => isSandbox ? _sandboxSalt       : _liveSalt;
  static String get paymentUrl => isSandbox ? _sandboxUrl        : _liveUrl;

  /// Generate secure hash (HMAC-SHA256)
  static String generateHash(Map<String, String> params) {
    final sorted = params.keys.toList()..sort();
    final values = sorted.map((k) => params[k]).join('&');
    final data   = '$salt&$values';
    final key    = utf8.encode(salt);
    final msg    = utf8.encode(data);
    final hmac   = Hmac(sha256, key);
    return hmac.convert(msg).toString();
  }

  /// Generate unique transaction reference
  static String generateTxnRef() {
    final now = DateTime.now();
    return 'BK${now.millisecondsSinceEpoch}';
  }

  /// Build payment parameters
  static Map<String, String> buildParams({
    required int amountPaisa, // Amount in paisa (Rs 299 = 29900)
    required String txnRef,
    required String customerPhone,
    required String description,
  }) {
    final now = DateTime.now();
    final dateTime = '${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}${now.hour.toString().padLeft(2,'0')}${now.minute.toString().padLeft(2,'0')}${now.second.toString().padLeft(2,'0')}';
    final expiry  = DateTime.now().add(const Duration(hours: 1));
    final expiryStr = '${expiry.year}${expiry.month.toString().padLeft(2,'0')}${expiry.day.toString().padLeft(2,'0')}${expiry.hour.toString().padLeft(2,'0')}${expiry.minute.toString().padLeft(2,'0')}${expiry.second.toString().padLeft(2,'0')}';

    final params = {
      'pp_Version':       '1.1',
      'pp_TxnType':       'MWALLET',
      'pp_Language':      'EN',
      'pp_MerchantID':    merchantId,
      'pp_SubMerchantID': '',
      'pp_Password':      password,
      'pp_BankID':        'TBANK',
      'pp_ProductID':     'RETL',
      'pp_TxnRefNo':      txnRef,
      'pp_Amount':        amountPaisa.toString(),
      'pp_TxnCurrency':   'PKR',
      'pp_TxnDateTime':   dateTime,
      'pp_BillReference': 'billRef',
      'pp_Description':   description,
      'pp_TxnExpiryDateTime': expiryStr,
      'pp_ReturnURL':     'https://bachakhana.pk/payment/return',
      'pp_SecureHash':    '',
      'ppmpf_1':          customerPhone,
    };

    // Generate hash (exclude pp_SecureHash)
    final hashParams = Map<String, String>.from(params)..remove('pp_SecureHash');
    params['pp_SecureHash'] = generateHash(hashParams);
    return params;
  }

  /// Launch JazzCash WebView Payment
  static Future<PaymentResult> launchPayment({
    required BuildContext context,
    required int amountRs,
    required String customerPhone,
    required String orderId,
    required String restaurantName,
  }) async {
    final txnRef   = generateTxnRef();
    final amtPaisa = amountRs * 100;
    final params   = buildParams(
      amountPaisa:   amtPaisa,
      txnRef:        txnRef,
      customerPhone: customerPhone,
      description:   'BachaKhana - $restaurantName Surprise Bag',
    );

    final result = await Navigator.push<PaymentResult>(
      context,
      MaterialPageRoute(builder: (_) => JazzCashWebView(
        paymentUrl: paymentUrl,
        params: params,
        txnRef: txnRef,
      )),
    );

    return result ?? PaymentResult(success: false, txnRef: txnRef);
  }
}

class PaymentResult {
  final bool   success;
  final String txnRef;
  final String? responseCode;
  final String? message;

  PaymentResult({
    required this.success,
    required this.txnRef,
    this.responseCode,
    this.message,
  });
}

/// WebView screen for JazzCash payment
class JazzCashWebView extends StatefulWidget {
  final String paymentUrl;
  final Map<String, String> params;
  final String txnRef;

  const JazzCashWebView({
    super.key,
    required this.paymentUrl,
    required this.params,
    required this.txnRef,
  });

  @override
  State<JazzCashWebView> createState() => _JazzCashWebViewState();
}

class _JazzCashWebViewState extends State<JazzCashWebView> {
  late InAppWebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Build form HTML to POST params
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayment());
  }

  void _loadPayment() {
    // Build HTML form that auto-submits with POST
    final formFields = widget.params.entries.map((e) =>
      '<input type="hidden" name="${e.key}" value="${e.value}">').join('\n');

    final html = '''
      <!DOCTYPE html>
      <html>
      <body onload="document.forms[0].submit()">
        <p style="font-family:sans-serif;text-align:center;padding:40px;">
          JazzCash par redirect ho raha hai...
        </p>
        <form method="POST" action="${widget.paymentUrl}">
          $formFields
        </form>
      </body>
      </html>
    ''';

    _ctrl.loadData(data: html, mimeType: 'text/html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JazzCash Payment'),
        backgroundColor: const Color(0xFFE63329),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context,
            PaymentResult(success: false, txnRef: widget.txnRef)),
        ),
      ),
      body: Stack(children: [
        InAppWebView(
          onWebViewCreated: (c) => _ctrl = c,
          onLoadStop: (c, url) {
            setState(() => _loading = false);
            // Check return URL for success
            if (url.toString().contains('bachakhana.pk/payment/return')) {
              _handleReturn(url.toString());
            }
          },
          shouldOverrideUrlLoading: (c, req) async {
            final url = req.request.url.toString();
            if (url.contains('bachakhana.pk/payment/return')) {
              _handleReturn(url);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator(
            color: Color(0xFFE63329))),
      ]),
    );
  }

  void _handleReturn(String url) {
    // Parse response — JazzCash appends pp_ResponseCode=000 for success
    final uri = Uri.parse(url);
    final code = uri.queryParameters['pp_ResponseCode'] ?? '';
    final success = code == '000';
    Navigator.pop(context, PaymentResult(
      success: success,
      txnRef: widget.txnRef,
      responseCode: code,
      message: success ? 'Payment successful!' : 'Payment failed. Code: $code',
    ));
  }
}

/// EasyPaisa Payment (similar approach)
class EasyPaisaService {
  static const String _sandboxUrl =
    'https://easypaystg.easypaisa.com.pk/easypay/Index.jsf';
  static const String _storeId = 'YOUR_STORE_ID';
  static const String _hashKey = 'YOUR_HASH_KEY';

  static Map<String, String> buildParams({
    required int amountRs,
    required String orderId,
    required String email,
  }) {
    final expiry = DateTime.now().add(const Duration(hours: 1));
    return {
      'storeId':         _storeId,
      'amount':          amountRs.toStringAsFixed(2),
      'postBackURL':     'https://bachakhana.pk/payment/easypaisa/return',
      'orderRefNum':     orderId,
      'expiryDate':      '${expiry.year}-${expiry.month.toString().padLeft(2,'0')}-${expiry.day.toString().padLeft(2,'0')} ${expiry.hour.toString().padLeft(2,'0')}:${expiry.minute.toString().padLeft(2,'0')}:${expiry.second.toString().padLeft(2,'0')}',
      'paymentMethod':   'MA_PAYMENT',
      'emailAddress':    email,
      'merchantPaymentMethod': 'MA_PAYMENT',
    };
  }
}
