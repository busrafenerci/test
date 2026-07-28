import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

class PredictionInfoScreen extends StatelessWidget {
  const PredictionInfoScreen({super.key});

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
          l10n.settingsPredictionsTitle,
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
            border: Border.all(
              color: const Color(0xFFECE7FA),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoHeading(
                title: l10n.predictionHowCreatedTitle,
              ),
              const SizedBox(height: 10),
              _InfoParagraph(
                text: l10n.predictionHowCreatedText,
              ),
              const SizedBox(height: 24),
              _InfoHeading(
                title: l10n.predictionEstimatedInfoTitle,
              ),
              const SizedBox(height: 10),
              _InfoBullet(
                text: l10n.predictionNextPeriodItem,
              ),
              _InfoBullet(
                text: l10n.predictionPmsItem,
              ),
              _InfoBullet(
                text: l10n.predictionFertileWindowItem,
              ),
              _InfoBullet(
                text: l10n.predictionOvulationItem,
              ),
              const SizedBox(height: 24),
              _InfoHeading(
                title: l10n.predictionWhyDatesChangeTitle,
              ),
              const SizedBox(height: 10),
              _InfoParagraph(
                text: l10n.predictionWhyDatesChangeText,
              ),
              const SizedBox(height: 24),
              const _WarningBox(),
              const SizedBox(height: 24),
              _InfoHeading(
                title: l10n.predictionHealthDecisionsTitle,
              ),
              const SizedBox(height: 10),
              _InfoParagraph(
                text: l10n.predictionHealthDecisionsText,
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.predictionWarningText,
              style: const TextStyle(
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

  const _InfoHeading({
    required this.title,
  });

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

  const _InfoParagraph({
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

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({
    required this.text,
  });

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
