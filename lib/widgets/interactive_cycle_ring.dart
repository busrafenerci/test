import 'package:flutter/material.dart';

enum CyclePhase {
  period,
  pms,
  ovulation,
  fertile,
}

class InteractiveCycleRing extends StatefulWidget {
  const InteractiveCycleRing({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<InteractiveCycleRing> createState() =>
      _InteractiveCycleRingState();
}

class _InteractiveCycleRingState
    extends State<InteractiveCycleRing> {
  CyclePhase? _selectedPhase;

  void _selectPhase(CyclePhase phase) {
    setState(() {
      if (_selectedPhase == phase) {
        _selectedPhase = null;
      } else {
        _selectedPhase = phase;
      }
    });
  }

  void _closeTooltip() {
    if (_selectedPhase == null) {
      return;
    }

    setState(() {
      _selectedPhase = null;
    });
  }

  PhaseTooltipData _getPhaseData(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.period:
        return const PhaseTooltipData(
          title: 'Regl dönemi',
          subtitle: '1 - 5. günler',
          icon: Icons.water_drop_rounded,
          color: Color(0xFFE85D75),
        );

      case CyclePhase.pms:
        return const PhaseTooltipData(
          title: 'PMS dönemi',
          subtitle: 'Regl öncesi günler',
          icon: Icons.bedtime_rounded,
          color: Color(0xFF8F7BD8),
        );

      case CyclePhase.ovulation:
        return const PhaseTooltipData(
          title: 'Yumurtlama dönemi',
          subtitle: 'Tahmini yumurtlama günü',
          icon: Icons.local_florist_rounded,
          color: Color(0xFFF1BE4B),
        );

      case CyclePhase.fertile:
        return const PhaseTooltipData(
          title: 'Doğurgan dönem',
          subtitle: 'Hamilelik ihtimali yüksek',
          icon: Icons.eco_rounded,
          color: Color(0xFF72C894),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _closeTooltip,
      child: AspectRatio(
        aspectRatio: 1.12,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        16,
                        18,
                        10,
                      ),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // PMS symbol touch area
                  Positioned(
                    left: width * 0.05,
                    top: height * 0.25,
                    child: _PhaseTouchArea(
                      size: 68,
                      onTap: () {
                        _selectPhase(CyclePhase.pms);
                      },
                    ),
                  ),

                  // Period symbol touch area
                  Positioned(
                    left: width * 0.50 - 34,
                    top: 0,
                    child: _PhaseTouchArea(
                      size: 68,
                      onTap: () {
                        _selectPhase(CyclePhase.period);
                      },
                    ),
                  ),

                  // Fertile symbol touch area
                  Positioned(
                    right: width * 0.01,
                    top: height * 0.38,
                    child: _PhaseTouchArea(
                      size: 72,
                      onTap: () {
                        _selectPhase(CyclePhase.fertile);
                      },
                    ),
                  ),

                  // Ovulation symbol touch area
                  Positioned(
                    left: width * 0.50 - 36,
                    bottom: 0,
                    child: _PhaseTouchArea(
                      size: 72,
                      onTap: () {
                        _selectPhase(CyclePhase.ovulation);
                      },
                    ),
                  ),

                  if (_selectedPhase != null)
                    _buildTooltip(
                      constraints: constraints,
                      phase: _selectedPhase!,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip({
    required BoxConstraints constraints,
    required CyclePhase phase,
  }) {
    final data = _getPhaseData(phase);

    double? left;
    double? right;
    double? top;
    double? bottom;

    switch (phase) {
      case CyclePhase.period:
        right = 18;
        top = 16;
        break;

      case CyclePhase.pms:
        left = 18;
        top = 20;
        break;

      case CyclePhase.fertile:
        right = 18;
        top = constraints.maxHeight * 0.15;
        break;

      case CyclePhase.ovulation:
        left = constraints.maxWidth / 2 - 92;
        bottom = 18;
        break;
    }

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Prevent the parent tap from closing the tooltip.
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: _PhaseTooltip(
            key: ValueKey(phase),
            data: data,
          ),
        ),
      ),
    );
  }
}

class _PhaseTouchArea extends StatelessWidget {
  const _PhaseTouchArea({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
      ),
    );
  }
}

class _PhaseTooltip extends StatelessWidget {
  const _PhaseTooltip({
    super.key,
    required this.data,
  });

  final PhaseTooltipData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 190,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            size: 18,
            color: data.color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF342D3D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF958E9B),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PhaseTooltipData {
  const PhaseTooltipData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}