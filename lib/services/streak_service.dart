import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  static DateTime _parse(String date) {
    final parts = date.split("-");
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static Future<void> updateStreak() async {
    final user = _auth.currentUser!;
    final ref = _db.collection('user_stats').doc(user.uid);

    final doc = await ref.get();

    final todayStr = _today();
    final today = _parse(todayStr);

    if (!doc.exists) {
      await ref.set({
        "currentStreak": 1,
        "bestStreak": 1,
        "lastAnsweredDate": todayStr,
      });
      return;
    }

    final data = doc.data()!;

    final lastDateStr = data["lastAnsweredDate"];
    final lastDate = _parse(lastDateStr);

    final difference = today.difference(lastDate).inDays;

    int current = data["currentStreak"] ?? 0;
    int best = data["bestStreak"] ?? 0;

    if (difference == 0) {
      // 🚫 ya sumó hoy → no hacer nada
      return;
    } else if (difference == 1) {
      current += 1;
    } else {
      current = 1;
    }

    if (current > best) {
      best = current;
    }

    await ref.set({
      "currentStreak": current,
      "bestStreak": best,
      "lastAnsweredDate": todayStr,
    });
  }

  static Stream<DocumentSnapshot> stream() {
    final user = _auth.currentUser!;
    return _db.collection('user_stats').doc(user.uid).snapshots();
  }
}
