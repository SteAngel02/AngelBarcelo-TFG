import 'package:flutter/material.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';
import '../../domain/avatar_entity.dart';

class ChartWidget extends StatelessWidget {
  final AvatarEntity avatar;

  const ChartWidget({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final statNames = [
      'fuerza',
      'inteligencia',
      'constitucion',
      'destreza',
      'sabiduria',
    ];
    final displayNames = [
      'Fuerza',
      'Inteligencia',
      'Constitución',
      'Destreza',
      'Sabiduría',
    ];

    final List<double> data = [];
    final List<String> labels = [];

    int maxLevel = 1;

    for (int i = 0; i < statNames.length; i++) {
      final statName = statNames[i];
      final idx = avatar.atributos.indexWhere((a) => a.name == statName);
      final level = idx >= 0 ? avatar.atributos[idx].level : 1;
      data.add(level.toDouble());
      labels.add('${displayNames[i]} Lv.\u00A0$level');
      if (level > maxLevel) maxLevel = level;
    }

    double tickMax = maxLevel.toDouble();
    List<double> ticks = [
      tickMax * 0.2,
      tickMax * 0.4,
      tickMax * 0.6,
      tickMax * 0.8,
      tickMax,
    ];

    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Center(
        child: RadarChartPlus(
          ticks: ticks,
          shape: RadarChartShape.polygon,
          horizontalLabels: true,
          labelSpacing: -12.0,
          labelPadding: 8.0,
          labels: labels,
          labelTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          tickTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
          dataSets: [
            RadarDataSet(
              data: data,
              borderColor: Colors.cyanAccent,
              fillColor: Colors.cyanAccent.withValues(alpha: 0.3),
              dotColor: Colors.cyanAccent,
            ),
          ],
        ),
      ),
    );
  }
}
