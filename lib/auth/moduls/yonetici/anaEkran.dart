import 'package:randevu_sistemi/utils/service/auth/auth_service.dart';
import 'package:flutter/material.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Rezervasyonları yükle
  Future<void> _rezervasyonlariYukle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.rezervasyonlariOlustur();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyonlar yüklendi')),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> rezervasyonYap(String saatId, String saat) async {
    try {
      // Önce rezervasyonun müsait olup olmadığını kontrol et
      bool isDolu = await _authService.rezervasyonDurumKontrol(saatId);
      if (isDolu) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu saat dilimi dolu!')),
          );
        }
        return;
      }

      String? rezervasyonOnayi = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Rezervasyon Onayı"),
          content: Text(
              "$saat saatine rezervasyon yapmak istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop("Onaylandı"),
              child: const Text("Onayla"),
            ),
          ],
        ),
      );

      if (rezervasyonOnayi != null && rezervasyonOnayi.isNotEmpty) {
        await _authService.rezervasyonOlustur(
          saatId: saatId,
          saat: saat,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rezervasyon başarıyla oluşturuldu!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halısaha Rezervasyon'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _authService.getRezervasyonlar(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rezervasyonlar yüklenemedi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _rezervasyonlariYukle,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Rezervasyonları Göster'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rezervasyon saatleri yüklenmedi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _rezervasyonlariYukle,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Rezervasyonları Göster'),
                  ),
                ],
              ),
            );
          }

          final rezervasyonlar = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bugün için Müsait Saatler',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rezervasyonlar.length,
                  itemBuilder: (context, index) {
                    final rezervasyon = rezervasyonlar[index];
                    final saatId = rezervasyon['id'];
                    final bool dolu = rezervasyon['dolu'] ?? false;

                    return InkWell(
                      onTap: dolu
                          ? null
                          : () => rezervasyonYap(saatId, rezervasyon['saat']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dolu
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: dolu ? Colors.red : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rezervasyon['saat'],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                dolu ? 'Dolu' : 'Müsait',
                                style: TextStyle(
                                  color: dolu ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (dolu &&
                                  rezervasyon['rezervasyonSahibiBilgileri']
                                          ?['isim']
                                      ?.isNotEmpty)
                                Text(
                                  rezervasyon['rezervasyonSahibiBilgileri']
                                      ['isim'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
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
