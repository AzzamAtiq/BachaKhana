import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class OrderService {
  final _col = FirebaseFirestore.instance.collection('orders');

  Future<String> place(OrderModel o) async {
    final d = await _col.add(o.toFirestore()); return d.id;
  }

  Stream<List<OrderModel>> streamForUser(String uid) =>
    _col.where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(OrderModel.fromFirestore).toList());

  Future<void> updateStatus(String id, String status) =>
    _col.doc(id).update({'status': status});
}
