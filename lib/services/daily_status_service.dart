import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyStatusService {
  static final user = FirebaseAuth.instance.currentUser!;

  static String get todayId {
    final now = DateTime.now();
    return "${user.uid}_${now.year}-${now.month}-${now.day}";
  }

  static DocumentReference get ref =>
      FirebaseFirestore.instance.collection('daily_status').doc(todayId);

  static Future<void> initDay() async {
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "uid": user.uid,
        "fecha": todayId,
        "pendientesResueltos": false,
        "resumenCompletado": false,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<DocumentSnapshot> stream() {
    return ref.snapshots();
  }

  static Future<void> setPendientesResueltos() async {
    await ref.update({"pendientesResueltos": true});
  }

  static Future<void> setResumenCompletado() async {
    await ref.update({"resumenCompletado": true});
  }
}
