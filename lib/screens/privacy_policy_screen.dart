import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  static const Color _primaryPurple = Color(0xFF7C5CE7);
  static const Color _darkPurple = Color(0xFF382C62);
  static const Color _backgroundColor = Color(0xFFF8F6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _darkPurple,
          ),
        ),
        title: const Text(
          'Gizlilik Politikası',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _darkPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          36,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFECE7FA),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyHeading(
                title: 'Gizliliğin bizim için önemli',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna, regl döngünü takip etmene yardımcı olmak amacıyla geliştirilmiştir. Uygulamaya kaydettiğin bilgiler hassas ve kişisel verilerdir.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(
                title: 'Verilerin nerede saklanır?',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Regl başlangıç ve bitiş tarihlerin, döngü ayarların ve uygulama içindeki diğer kayıtların yalnızca kendi cihazında saklanır.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(
                title: 'Verilerin paylaşılır mı?',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna, kaydettiğin regl ve döngü bilgilerini herhangi bir sunucuya göndermez, üçüncü taraflarla paylaşmaz ve reklam amacıyla kullanmaz.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(
                title: 'Verilerini nasıl silebilirsin?',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Ayarlar ekranındaki “Tüm Verileri Sıfırla” seçeneğini kullanarak cihazında saklanan tüm regl kayıtlarını ve uygulama ayarlarını kalıcı olarak silebilirsin.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(
                title: 'Sağlık bilgisi',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna tarafından gösterilen regl, PMS, doğurgan dönem ve ovülasyon tarihleri yalnızca tahmindir. Uygulama tıbbi tavsiye, teşhis veya tedavi hizmeti sunmaz.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(
                title: 'Değişiklikler',
              ),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Uygulamaya yeni özellikler eklendiğinde bu gizlilik politikası güncellenebilir. Güncel metne her zaman Ayarlar ekranından ulaşabilirsin.',
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: _primaryPurple,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verilerin cihazında ve senin kontrolünde kalır.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _darkPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyHeading extends StatelessWidget {
  final String title;

  const _PrivacyHeading({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: PrivacyPolicyScreen._darkPurple,
      ),
    );
  }
}

class _PrivacyParagraph extends StatelessWidget {
  final String text;

  const _PrivacyParagraph({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Color(0xFF675F78),
      ),
    );
  }
}