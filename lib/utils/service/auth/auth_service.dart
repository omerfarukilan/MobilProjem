import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_sistemi/utils/service/auth/i_auth_service.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _rezervasyonlarCollection = 'rezervasyonlar';
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

  Stream<List<Map<String, dynamic>>> getRezervasyonlar() {
    final DateTime bugun = DateTime.now();
    final String bugunStr = "${bugun.year}-${bugun.month}-${bugun.day}";

    return _firestore
        .collection(_rezervasyonlarCollection)
        .where('tarih', isEqualTo: bugunStr)
        .snapshots()
        .map((snapshot) {
      var docs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      docs.sort((a, b) => (a['saat'] as String).compareTo(b['saat'] as String));

      return docs;
    });
  }

  Future<void> rezervasyonlariOlustur() async {
    final List<String> saatler = [
      "09:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00",
      "20:00",
      "21:00",
      "22:00",
      "23:00"
    ];

    final batch = _firestore.batch();
    final String bugun =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    // Mevcut rezervasyonları kontrol et
    final mevcutRezervasyonlar = await _firestore
        .collection(_rezervasyonlarCollection)
        .where('tarih', isEqualTo: bugun)
        .get();

    // Eğer bugün için rezervasyonlar zaten oluşturulmuşsa, tekrar oluşturma
    if (mevcutRezervasyonlar.docs.isNotEmpty) {
      return;
    }

    for (String saat in saatler) {
      final String saatId = '${bugun}_$saat'.replaceAll(':', '');
      final docRef =
          _firestore.collection(_rezervasyonlarCollection).doc(saatId);

      batch.set(
          docRef,
          {
            'saat': saat,
            'tarih': bugun,
            'dolu': false,
            'rezervasyonSahibiId': '',
            'rezervasyonSahibiBilgileri': {
              'isim': '',
              'email': '',
              'telefon': '',
              'yas': '',
            },
            'rezervasyonZamani': null,
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> rezervasyonOlustur({
    required String saatId,
    required String saat,
  }) async {
    try {
      // Giriş yapan kullanıcının UID'sini al
      final user = _auth.currentUser;

      if (user == null) {
        throw 'Kullanıcı giriş yapmamış!';
      }

      // Kullanıcı bilgilerini getir
      final kullaniciDoc =
          await _firestore.collection('kullanici').doc(user.uid).get();

      if (!kullaniciDoc.exists) {
        throw 'Kullanıcı bilgileri bulunamadı!';
      }

      // Kullanıcı bilgilerini al
      final kullaniciBilgileri = kullaniciDoc.data() as Map<String, dynamic>;

      // Rezervasyonun mevcut durumunu kontrol et
      final rezervasyonDoc =
          await _firestore.collection('rezervasyonlar').doc(saatId).get();

      if (!rezervasyonDoc.exists) {
        throw 'Bu saat için rezervasyon kaydı bulunamadı!';
      }

      if (rezervasyonDoc.data()?['dolu'] == true) {
        throw 'Bu saat dilimi dolu!';
      }

      // Rezervasyonu güncelle
      await _firestore.collection('rezervasyonlar').doc(saatId).set({
        'dolu': true, // Dolu durumunu true yap
        'rezervasyonSahibiId': user.uid,
        'rezervasyonSahibiBilgileri': {
          'isim': kullaniciBilgileri['kullaniciİsmi'] ?? '',
          'email': kullaniciBilgileri['kullaniciEmail'] ?? '',
          'telefon': kullaniciBilgileri['kullaniciTel'] ?? '',
          'yas': kullaniciBilgileri['kullaniciYas'] ?? '',
        },
        'rezervasyonZamani': FieldValue.serverTimestamp(),
        'saat': saat,
        'tarih':
            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
      }, SetOptions(merge: true)); // merge: true ile diğer alanları koruyoruz
    } catch (e) {
      throw 'Rezervasyon oluşturulamadı: $e';
    }
  }

  Future<bool> rezervasyonDurumKontrol(String saatId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_rezervasyonlarCollection)
          .doc(saatId)
          .get();

      return doc.exists && (doc.data() as Map<String, dynamic>)['dolu'] == true;
    } catch (e) {
      throw 'Rezervasyon durumu kontrol edilemedi: $e';
    }
  }

  Future<void> rezervasyonIptal(String saatId) async {
    try {
      await _firestore
          .collection(_rezervasyonlarCollection)
          .doc(saatId)
          .update({
        'dolu': false,
        'rezervasyonSahibiId': '',
        'rezervasyonSahibiBilgileri': {
          'isim': '',
          'email': '',
          'telefon': '',
          'yas': '',
        },
        'rezervasyonZamani': null,
      });
    } catch (e) {
      throw 'Rezervasyon iptal edilemedi: $e';
    }
  }
}
