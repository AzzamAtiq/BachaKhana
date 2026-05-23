import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class RestaurantService {
  final _col = FirebaseFirestore.instance.collection('restaurants');
  final _db  = FirebaseFirestore.instance;

  Stream<List<RestaurantModel>> streamAll({String? city}) {
    Query q = _col.where('isApproved', isEqualTo: true);
    if (city != null && city != 'Sab') q = q.where('city', isEqualTo: city);
    return q.orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map(RestaurantModel.fromFirestore).toList());
  }

  Future<RestaurantModel?> getOne(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? RestaurantModel.fromFirestore(d) : null;
  }

  Future<String> add(RestaurantModel r) async {
    final d = await _col.add(r.toFirestore()); return d.id;
  }

  Future<void> reduceBags(String id) =>
    _col.doc(id).update({'bagsLeft': FieldValue.increment(-1)});

  Future<void> addReview(String id, ReviewModel review) =>
    _col.doc(id).update({
      'reviews': FieldValue.arrayUnion([review.toMap()]),
      'reviewCount': FieldValue.increment(1),
    });
}
