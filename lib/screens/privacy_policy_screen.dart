import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color _primaryPurple = Color(0xFF7C5CE7);
  static const Color _darkPurple = Color(0xFF382C62);
  static const Color _backgroundColor = Color(0xFFF8F6FF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.privacyTitle,
          style: const TextStyle(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyHeading(title: l10n.privacyIntroTitle,),
              SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyIntroText,
              ),
              const SizedBox(height: 24),
              _PrivacyHeading(title: l10n.privacyIntroText,),
              const SizedBox(height: 10),
              _PrivacyBullet(text: l10n.privacyPeriodDates),
              _PrivacyBullet(text: l10n.privacyCycleLength),
              _PrivacyBullet(text: l10n.privacyPeriodLength),
              _PrivacyBullet(text: l10n.privacySetupStatus),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacyStorageTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyStorageText,
              ),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacyInternetTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyInternetText,
              ),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacySharingTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacySharingText,
              ),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacyDeleteTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyDeleteText,
              ),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacyPredictionsTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyPredictionsText,
              ),
              const SizedBox(height: 16),

              const _PrivacyWarning(),

              const SizedBox(height: 24),
              _PrivacyHeading(
                title: l10n.privacyMedicalTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyMedicalText,
              ),
              const SizedBox(height: 24),

              _PrivacyHeading(
                title: l10n.privacyChangesTitle,
              ),
              const SizedBox(height: 10),
              _PrivacyParagraph(
                text: l10n.privacyChangesText,
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
                     l10n.privacyFooterText,
                      style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF2D79D),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB67800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.privacyWarningText,
              style: const TextStyle(
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
