//lib/services/user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🆕 CREAR USUARIO
  Future<String?> crearUsuario({
    required String nombres,
    required String correo,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: password.trim(),
      );

      String uid = cred.user!.uid;

      await _firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nombres': nombres,
        'correo': correo,
        'estado': true,
        'fecha_creacion': FieldValue.serverTimestamp(),
      });

      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("⚠️ Correo ya registrado");
        return "correo_existente";
      }

      print("🔥 Firebase error: ${e.message}");
      return null;
    } catch (e) {
      print("🔥 Error general: $e");
      return null;
    }
  }

  // 📄 OBTENER USUARIO POR UID
  Future<Map<String, dynamic>?> getUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print("🔥 Error obteniendo usuario: $e");
      return null;
    }
  }

  // 📡 STREAM USUARIOS
  Stream<QuerySnapshot> obtenerUsuarios() {
    return _firestore.collection('usuarios').snapshots();
  }
}
