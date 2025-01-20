import 'package:flutter/material.dart';
import 'package:randevu_sistemi/utils/service/auth/auth_service.dart';

class AdminAnaEkran extends StatefulWidget {
  const AdminAnaEkran({super.key});

  @override
  State<AdminAnaEkran> createState() => _AdminAnaEkranState();
}

class _AdminAnaEkranState extends State<AdminAnaEkran> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _rezervasyonIptal(
      String saatId, Map<String, dynamic> rezervasyon) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyon İptali'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${rezervasyon['saat']} saatindeki rezervasyonu iptal etmek istediğinize emin misiniz?'),
            const SizedBox(height: 8),
            Text(
                'Rezervasyon Sahibi: ${rezervasyon['rezervasyonSahibiBilgileri']['isim']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (onay == true) {
      try {
        setState(() => _isLoading = true);
        await _authService.rezervasyonIptal(saatId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rezervasyon başarıyla iptal edildi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _rezervasyonDetayGoster(Map<String, dynamic> rezervasyon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${rezervasyon['saat']} - Rezervasyon Detayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İsim: ${rezervasyon['rezervasyonSahibiBilgileri']['isim']}'),
            const SizedBox(height: 8),
            Text(
                'E-posta: ${rezervasyon['rezervasyonSahibiBilgileri']['email']}'),
            const SizedBox(height: 8),
            Text(
                'Telefon: ${rezervasyon['rezervasyonSahibiBilgileri']['telefon']}'),
            const SizedBox(height: 8),
            Text('Yaş: ${rezervasyon['rezervasyonSahibiBilgileri']['yas']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _authService.getRezervasyonlar(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Rezervasyonlar yüklenirken bir hata oluştu'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rezervasyonlar = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bugünün Rezervasyonları',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rezervasyonlar.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final rezervasyon = rezervasyonlar[index];
                    final bool dolu = rezervasyon['dolu'] ?? false;
                    final saatId = rezervasyon['id'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: dolu ? Colors.red : Colors.green,
                          child: Text(
                            rezervasyon['saat'].substring(0, 2),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(rezervasyon['saat']),
                        subtitle: Text(
                          dolu
                              ? 'Rezervasyon Sahibi: ${rezervasyon['rezervasyonSahibiBilgileri']['isim']}'
                              : 'Müsait',
                        ),
                        trailing: dolu
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () =>
                                        _rezervasyonDetayGoster(rezervasyon),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined),
                                    color: Colors.red,
                                    onPressed: _isLoading
                                        ? null
                                        : () => _rezervasyonIptal(
                                            saatId, rezervasyon),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
