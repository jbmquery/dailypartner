//lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 LOGIN
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = cred.user!.uid;

      DocumentReference ref = _firestore.collection('usuarios').doc(uid);
      DocumentSnapshot doc = await ref.get();

      // 🧠 SI NO EXISTE → LO CREA AUTOMÁTICAMENTE
      if (!doc.exists) {
        await ref.set({
          'uid': uid,
          'nombres': 'Usuario',
          'correo': email,
          'estado': true,
          'fecha_creacion': FieldValue.serverTimestamp(),
          'tema': 'chill',
        });

        final newDoc = await ref.get();
        return newDoc.data() as Map<String, dynamic>;
      }

      return doc.data() as Map<String, dynamic>;
    } on FirebaseAuthException catch (e) {
      print("🔥 Error login: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("🔥 Error general login: $e");
      return null;
    }
  }

  // 👤 USUARIO ACTUAL
  User? get usuarioActual => _auth.currentUser;

  // 🔁 STREAM AUTH (para tu AuthWrapper)
  Stream<User?> get authState => _auth.authStateChanges();

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
