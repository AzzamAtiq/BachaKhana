import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../services/order_service.dart';

class AppState extends ChangeNotifier {
  final _auth  = AuthService();
  final _rests = RestaurantService();
  final _ords  = OrderService();

  UserModel?             _user;
  List<RestaurantModel>  _restaurants = [];
  List<OrderModel>       _orders      = [];
  bool                   _loading     = false;
  String?                _error;
  String                 _city        = 'Sab';
  String                 _category    = 'all';
  String                 _search      = '';

  StreamSubscription? _restSub, _ordSub;

  // ── GETTERS ──
  UserModel?            get currentUser       => _user;
  List<RestaurantModel> get allRestaurants    => _restaurants;
  List<OrderModel>      get orders            => _orders;
  bool                  get isLoading         => _loading;
  String?               get error             => _error;
  String                get selectedCity      => _city;
  String                get selectedCategory  => _category;
  bool                  get isLoggedIn        => _user != null;
  int                   get totalSaved        => _orders.fold(0,(s,o)=>s+o.saved);

  bool isFavorite(String id) => _user?.favoriteIds.contains(id) ?? false;

  List<RestaurantModel> get filteredRestaurants => _restaurants.where((r) {
    final catOk  = _category == 'all' || r.category == _category;
    final cityOk = _city == 'Sab' || r.city == _city;
    final sq     = _search.toLowerCase();
    final srcOk  = sq.isEmpty ||
      r.name.toLowerCase().contains(sq) ||
      r.location.toLowerCase().contains(sq);
    return catOk && cityOk && srcOk;
  }).toList();

  List<RestaurantModel> get featuredRestaurants =>
    _restaurants.where((r) => r.bagsLeft > 0 && r.bagsLeft <= 3).toList();

  AppState() { _auth.authStateChanges.listen(_onAuth); }

  Future<void> _onAuth(User? fb) async {
    if (fb == null) {
      _user = null; _orders = []; _ordSub?.cancel();
    } else {
      _user = await _auth.getUser(fb.uid);
      _listenOrders(fb.uid);
    }
    notifyListeners();
    _listenRests();
  }

  void _listenRests() {
    _restSub?.cancel();
    _restSub = _rests.streamAll(city: _city == 'Sab' ? null : _city)
      .listen((list) { _restaurants = list; notifyListeners(); });
  }

  void _listenOrders(String uid) {
    _ordSub?.cancel();
    _ordSub = _ords.streamForUser(uid)
      .listen((list) { _orders = list; notifyListeners(); });
  }

  // ── AUTH ──
  Future<void> login(String email, String pass) async {
    _set(loading: true);
    try { _user = await _auth.login(email, pass); }
    catch (e) { _error = e.toString(); }
    _set(loading: false);
  }

  Future<void> signup({required String name, required String email,
    required String password, required String phone, required String city}) async {
    _set(loading: true);
    try { _user = await _auth.signUp(
      name: name, email: email, password: password, phone: phone, city: city); }
    catch (e) { _error = e.toString(); }
    _set(loading: false);
  }

  Future<void> logout() async {
    await _auth.logout(); _user = null; _orders = [];
    notifyListeners();
  }

  // ── FAVORITES ──
  Future<void> toggleFavorite(String restId) async {
    if (_user == null) return;
    await _auth.toggleFavorite(_user!.uid, restId);
    _user = await _auth.getUser(_user!.uid);
    notifyListeners();
  }

  // ── ORDER (with payment result) ──
  Future<String?> placeOrder({
    required RestaurantModel restaurant,
    required SlotModel slot,
    required String selectedTime,
    required bool isDelivery,
    required String paymentMethod,
    String? transactionId,
  }) async {
    if (_user == null) return null;
    _set(loading: true);
    try {
      final total = isDelivery ? slot.bagPrice + restaurant.deliveryCharge : slot.bagPrice;
      final order = OrderModel(
        id: '', restaurantId: restaurant.firestoreId,
        restaurantName: restaurant.name, emoji: restaurant.emoji,
        bagName: slot.name, pickupTime: isDelivery ? null : selectedTime,
        price: total, saved: slot.origPrice - slot.bagPrice,
        createdAt: DateTime.now(), isDelivery: isDelivery,
        userId: _user!.uid, paymentMethod: paymentMethod,
        paymentStatus: 'paid', transactionId: transactionId,
      );
      final id = await _ords.place(order);
      await _rests.reduceBags(restaurant.firestoreId);
      _set(loading: false);
      return id;
    } catch (e) { _error = e.toString(); _set(loading: false); return null; }
  }

  Future<void> addRestaurant(RestaurantModel r) async {
    _set(loading: true);
    try { await _rests.add(r); }
    catch (e) { _error = e.toString(); }
    _set(loading: false);
  }

  // ── FILTERS ──
  void setCategory(String c) { _category = c; notifyListeners(); }
  void setCity(String c)     { _city = c; _listenRests(); notifyListeners(); }
  void setSearch(String s)   { _search = s; notifyListeners(); }
  void clearError()          { _error = null; notifyListeners(); }

  void _set({bool? loading}) {
    if (loading != null) _loading = loading;
    notifyListeners();
  }

  @override
  void dispose() { _restSub?.cancel(); _ordSub?.cancel(); super.dispose(); }
}
