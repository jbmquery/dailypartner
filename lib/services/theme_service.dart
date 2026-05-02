//lib/services/theme_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  static Stream<String> modoStream() {
    return FirebaseAuth.instance.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value("chill");
      }

      return FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return "chill";
            return doc.data()?["modo"] ?? "chill";
          });
    });
  }
}
