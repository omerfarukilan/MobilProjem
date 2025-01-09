import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(
      String isim, int telefon, int yas, String email, String password);
  Future<void> signOut();

  Future<bool> signInAdmin(String email, String password);
}
