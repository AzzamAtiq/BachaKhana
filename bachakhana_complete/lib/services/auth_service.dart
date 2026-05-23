import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User?        get currentUser      => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp({
    required String name, required String email,
    required String password, required String phone, required String city,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());
      final user = UserModel(
        uid: cred.user!.uid, name: name.trim(), email: email.trim(),
        phone: phone.trim(), city: city, createdAt: DateTime.now());
      await _db.collection('users').doc(cred.user!.uid).set(user.toFirestore());
      return user;
    } on FirebaseAuthException catch (e) { throw _msg(e.code); }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
      return await getUser(cred.user!.uid);
    } on FirebaseAuthException catch (e) { throw _msg(e.code); }
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<void> updateUser(UserModel user) =>
    _db.collection('users').doc(user.uid).update(user.toFirestore());

  Future<void> toggleFavorite(String uid, String restId) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    final favs = List<String>.from(doc.data()?['favoriteIds'] ?? []);
    favs.contains(restId) ? favs.remove(restId) : favs.add(restId);
    await ref.update({'favoriteIds': favs});
  }

  Future<void> resetPassword(String email) =>
    _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> logout() => _auth.signOut();

  String _msg(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Yeh email pehle se registered hai.';
      case 'weak-password':        return 'Password 6+ characters ka hona chahiye.';
      case 'user-not-found':       return 'Email registered nahi hai.';
      case 'wrong-password':       return 'Password ghalat hai.';
      case 'invalid-email':        return 'Email sahi nahi hai.';
      case 'too-many-requests':    return 'Zyada attempts. Kuch der baad try karein.';
      default: return 'Kuch masla hua. Dobara try karein.';
    }
  }
}
