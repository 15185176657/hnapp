import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.primaryValues,
    required this.secondaryValues,
  });

  final List<double> primaryValues;
  final List<double> secondaryValues;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      ...primaryValues,
      ...secondaryValues,
    ].fold<double>(1, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(primaryValues.length, (index) {
          final generationHeight = primaryValues[index] / maxValue;
          final consumptionHeight = secondaryValues[index] / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _Bar(
                      heightFactor: generationHeight,
                      color: AppColors.solar,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: _Bar(
                      heightFactor: consumptionHeight,
                      color: AppColors.ocean,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.color});

  final double heightFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor.clamp(0.04, 1),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }
}