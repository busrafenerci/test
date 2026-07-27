import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'Hakkında',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _darkPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFECE7FA)),
          ),
          child: const Column(
            children: [
              ClipRRect(
  borderRadius: BorderRadius.all(
    Radius.circular(18),
  ),
  child: Image(
    image: AssetImage(
      'assets/icons/within_app_icon.png',
    ),
    width: 68,
    height: 68,
    fit: BoxFit.cover,
  ),
),
              SizedBox(height: 14),
              Text(
                'Within',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _darkPurple,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sürüm 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF81798F),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Within, regl döngülerini kolayca kaydetmeye ve kişisel döngü tahminlerini takip etmeye yardımcı olmak amacıyla geliştirilmiştir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF675F78),
                ),
              ),
              SizedBox(height: 24),
              Divider(color: Color(0xFFECE7FA)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: Color(0xFFD9577D),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Türkiye’de geliştirildi.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _darkPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Text(
                'İletişim adresi mağaza yayını öncesinde eklenecektir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF81798F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
