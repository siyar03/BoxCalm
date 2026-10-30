import 'package:flutter/material.dart';

/// The four sides of the breath, in seconds.
@immutable
class BreathPattern {
  const BreathPattern({
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
  });

  final int inhale;
  final int hold1;
  final int exhale;
  final int hold2;

  static const box = BreathPattern(inhale: 4, hold1: 4, exhale: 4, hold2: 4);

  int get cycleSeconds => inhale + hold1 + exhale + hold2;

  Duration get cycleDuration => Duration(seconds: cycleSeconds);

  bool get hasHolds => hold1 > 0 || hold2 > 0;

  String get label => '$inhale · $hold1 · $exhale · $hold2';

  BreathPattern copyWith({int? inhale, int? hold1, int? exhale, int? hold2}) {
    return BreathPattern(
      inhale: inhale ?? this.inhale,
      hold1: hold1 ?? this.hold1,
      exhale: exhale ?? this.exhale,
      hold2: hold2 ?? this.hold2,
    );
  }

  Map<String, dynamic> toMap() => {
        'inhale': inhale,
        'hold1': hold1,
        'exhale': exhale,
        'hold2': hold2,
      };

  factory BreathPattern.fromMap(Map<dynamic, dynamic> map) => BreathPattern(
        inhale: (map['inhale'] as num?)?.round() ?? 4,
        hold1: (map['hold1'] as num?)?.round() ?? 4,
        exhale: (map['exhale'] as num?)?.round() ?? 4,
        hold2: (map['hold2'] as num?)?.round() ?? 4,
      );

  List<double> get segments {
    final total = cycleSeconds.toDouble();
    if (total <= 0) return const [0.25, 0.25, 0.25, 0.25];
    return [inhale / total, hold1 / total, exhale / total, hold2 / total];
  }

  @override
  bool operator ==(Object other) =>
      other is BreathPattern &&
      other.inhale == inhale &&
      other.hold1 == hold1 &&
      other.exhale == exhale &&
      other.hold2 == hold2;

  @override
  int get hashCode => Object.hash(inhale, hold1, exhale, hold2);
}
