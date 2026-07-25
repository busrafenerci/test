import 'package:flutter/material.dart';

class PredictionInfoScreen extends StatelessWidget {
  const PredictionInfoScreen({super.key});

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
          'Tahminler Hakkında',
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
              _InfoHeading(title: 'Tahminler nasıl oluşturulur?'),
              SizedBox(height: 10),
              _InfoParagraph(
                text:
                    'Luna, girdiğin regl başlangıç ve bitiş kayıtlarını kullanarak döngü uzunluğunu ve regl süresini tahmin eder. Yeterli kayıt bulunmadığında, ayarlarda seçtiğin varsayılan değerler ve genel döngü hesaplama yöntemleri kullanılır.',
              ),
              SizedBox(height: 24),
              _InfoHeading(title: 'Hangi bilgiler tahminidir?'),
              SizedBox(height: 10),
              _InfoBullet(text: 'Bir sonraki regl tarihi ve tahmini regl günleri'),
              _InfoBullet(text: 'PMS dönemi'),
              _InfoBullet(text: 'Doğurgan dönem'),
              _InfoBullet(text: 'Yumurtlama günü'),
              SizedBox(height: 24),
              _InfoHeading(title: 'Tarihler neden değişebilir?'),
              SizedBox(height: 10),
              _InfoParagraph(
                text:
                    'Her kişinin döngüsü farklıdır. Stres, hastalık, ilaç kullanımı, uyku düzeni, seyahat, hormonal değişiklikler ve başka etkenler gerçek tarihlerin tahminlerden farklı olmasına neden olabilir.',
              ),
              SizedBox(height: 24),
              _WarningBox(),
              SizedBox(height: 24),
              _InfoHeading(title: 'Sağlıkla ilgili kararlar'),
              SizedBox(height: 10),
              _InfoParagraph(
                text:
                    'Luna tıbbi tanı koymaz, tedavi önermez ve doktor değerlendirmesinin yerine geçmez. Döngünde olağan dışı veya seni endişelendiren bir değişiklik varsa bir sağlık uzmanına danışmalısın.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D79D)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB67800),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Doğurgan dönem ve yumurtlama tahminleri, gebelikten korunmak veya gebelik elde etmek için tek başına kullanılmamalıdır.',
              style: TextStyle(
                fontSize: 14,
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

class _InfoHeading extends StatelessWidget {
  final String title;

  const _InfoHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: PredictionInfoScreen._darkPurple,
      ),
    );
  }
}

class _InfoParagraph extends StatelessWidget {
  final String text;

  const _InfoParagraph({required this.text});

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

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({required this.text});

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
              color: PredictionInfoScreen._primaryPurple,
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
