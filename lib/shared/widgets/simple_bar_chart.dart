import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.primaryValues,
    required this.secondaryValues,
    this.labels,
    this.unit = 'kWh',
  });

  final List<double> primaryValues;
  final List<double> secondaryValues;

  /// Optional labels rendered under each bar group (for example hour markers).
  final List<String>? labels;

  /// Unit shown next to the Y-axis max reference value.
  final String unit;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      ...primaryValues,
      ...secondaryValues,
    ].fold<double>(1, (max, value) => value > max ? value : max);

    final axisStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 10,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple Y-axis scale reference so bar heights are quantifiable.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${maxValue.toStringAsFixed(1)} $unit', style: axisStyle),
            Text('0', style: axisStyle),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 160,
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
        ),
        if (labels != null) ...[
          const SizedBox(height: 6),
          Row(
            children: List.generate(primaryValues.length, (index) {
              final label = index < labels!.length ? labels![index] : '';
              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: axisStyle,
                ),
              );
            }),
          ),
        ],
      ],
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
