import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_sistemi/utils/service/auth/i_auth_service.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      var userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUp(
      String isim, int telefon, int yas, String email, String password) async {
    try {
      var userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore
          .collection("kullanici")
          .doc(userCredential.user!.uid)
          .set({
        'kullaniciİsmi': isim,
        'kullaniciEmail': email,
        'kullaniciTel': telefon,
        'kullaniciYas': yas,
        'role': 'kullanici',
      });

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> signInAdmin(String email, String password) async {
    try {
      var querySnapshot = await _firestore
          .collection('yonetici')
          .where('email', isEqualTo: email)
          .where('yoneticiSifre', isEqualTo: password)
          .get();
      print('Firestore query result: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isNotEmpty) {
        var role = querySnapshot.docs.first.data()['role'];
        print('Admin role: $role');
        return role == 'admin';
      } else {
        print('Admin bulunamadı');
        return false;
      }
    } catch (e) {
      print('Admin giriş hatası: ${e.toString()}');
      return false;
    }
  }
}
