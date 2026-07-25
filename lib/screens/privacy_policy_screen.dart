import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          onPressed: () => Navigator.of(context).pop(),
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFECE7FA)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyHeading(title: 'Gizliliğin bizim için önemli'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna, regl döngünü takip etmene yardımcı olmak amacıyla geliştirilmiştir. Uygulamaya kaydettiğin regl ve döngü bilgileri hassas kişisel verilerdir.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Hangi veriler kaydedilir?'),
              SizedBox(height: 10),
              _PrivacyBullet(text: 'Regl başlangıç ve bitiş tarihleri'),
              _PrivacyBullet(text: 'Ortalama döngü uzunluğu'),
              _PrivacyBullet(text: 'Tahmini regl süresi'),
              _PrivacyBullet(text: 'Uygulama kurulumunun tamamlanma bilgisi'),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Verilerin nerede saklanır?'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Kayıtların yalnızca kendi cihazında yerel olarak saklanır. Luna hesap oluşturmanı istemez ve mevcut sürümde verilerini bir çevrim içi hesaba eşitlemez.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'İnternet, konum ve hesap'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Mevcut sürüm temel döngü takibi için internet bağlantısına ihtiyaç duymaz. Konum bilgisi toplamaz ve kullanıcı hesabı oluşturmaz.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Verilerin paylaşılır mı?'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna, kaydettiğin sağlık ve döngü bilgilerini herhangi bir sunucuya göndermez, üçüncü taraflarla paylaşmaz ve reklam amacıyla kullanmaz.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Verilerini nasıl silebilirsin?'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Ayarlar ekranındaki “Tüm Verileri Sıfırla” seçeneğini kullanarak cihazında saklanan regl kayıtlarını ve uygulama ayarlarını kalıcı olarak silebilirsin. Uygulamayı kaldırmak da cihazdaki yerel uygulama verilerini kaldırabilir.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Tahminler ve sağlık bilgisi'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna tarafından gösterilen regl, PMS, doğurgan dönem ve yumurtlama tarihleri yaklaşık tahminlerdir. Tahminler, girdiğin kayıtlar, seçtiğin ayarlar ve genel döngü hesaplama yöntemleri temel alınarak oluşturulur. Gerçek tarihler kişiden kişiye ve döngüden döngüye değişebilir.',
              ),
              SizedBox(height: 16),
              _PrivacyWarning(),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Tıbbi sorumluluk'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Luna bir tıbbi cihaz değildir; tıbbi tavsiye, teşhis veya tedavi sunmaz. Doktor değerlendirmesinin yerine geçmez. Doğurgan dönem ve yumurtlama tahminleri gebelikten korunmak veya gebelik elde etmek için tek başına kullanılmamalıdır.',
              ),
              SizedBox(height: 24),
              _PrivacyHeading(title: 'Değişiklikler'),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text:
                    'Uygulamaya yeni özellikler, çevrim içi hizmetler, analiz veya reklam araçları eklenirse bu gizlilik politikası güncellenecektir. Güncel metne Ayarlar ekranından ulaşabilirsin.',
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
                      'Mevcut sürümde verilerin cihazında ve senin kontrolünde kalır.',
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

class _PrivacyWarning extends StatelessWidget {
  const _PrivacyWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2D79D)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFB67800)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tahminler doğum kontrol yöntemi değildir ve gebelik planlamasında tek başına güvenilir kabul edilmemelidir.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6F5218),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyHeading extends StatelessWidget {
  final String title;

  const _PrivacyHeading({required this.title});

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

  const _PrivacyParagraph({required this.text});

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

class _PrivacyBullet extends StatelessWidget {
  final String text;

  const _PrivacyBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 6,
              color: PrivacyPolicyScreen._primaryPurple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF675F78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
