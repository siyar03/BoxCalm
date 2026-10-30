import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'breath_pattern.dart';

enum PresetCategory {
  tactical('Tactical', 'Focus under pressure'),
  relax('Relax', 'Downshift the nervous system'),
  sleep('Sleep', 'Slow the mind for rest'),
  energy('Energy', 'A gentle wake-up'),
  custom('Mine', 'Your own pattern');

  const PresetCategory(this.label, this.tagline);
  final String label;
  final String tagline;
}

@HiveType(typeId: 1)
class Preset extends HiveObject {
  Preset({
    required this.id,
    required this.name,
    required this.description,
    required this.pattern,
    this.targetMinutes = 5,
    this.targetCycles,
    this.isBuiltIn = false,
    this.isFavorite = false,
    this.category = PresetCategory.custom,
    this.paletteId,
    this.progressive = false,
    this.progressiveEvery = 5,
    this.sortOrder = 0,
    this.ambient = 'none',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  BreathPattern pattern;

  @HiveField(4)
  int targetMinutes;

  @HiveField(5)
  int? targetCycles;

  @HiveField(6)
  bool isBuiltIn;

  @HiveField(7)
  bool isFavorite;

  @HiveField(8)
  int categoryIndex;

  @HiveField(9)
  String? paletteId;

  @HiveField(10)
  bool progressive;

  @HiveField(11)
  int progressiveEvery;

  @HiveField(12)
  int sortOrder;

  @HiveField(13)
  String ambient;

  PresetCategory get category =>
      categoryIndex >= 0 && categoryIndex < PresetCategory.values.length
          ? PresetCategory.values[categoryIndex]
          : PresetCategory.custom;

  set category(PresetCategory value) => categoryIndex = value.index;

  bool get usesCycles => targetCycles != null && targetCycles! > 0;

  int get targetValue => usesCycles ? targetCycles! : targetMinutes;

  String get targetLabel =>
      usesCycles ? '$targetCycles cycles' : '$targetMinutes min';

  Preset copyWith({
    String? id,
    String? name,
    String? description,
    BreathPattern? pattern,
    int? targetMinutes,
    int? targetCycles,
    bool clearCycles = false,
    bool? isBuiltIn,
    bool? isFavorite,
    PresetCategory? category,
    String? paletteId,
    bool? progressive,
    int? progressiveEvery,
    int? sortOrder,
    String? ambient,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pattern: pattern ?? this.pattern,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      targetCycles: clearCycles ? null : (targetCycles ?? this.targetCycles),
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      paletteId: paletteId ?? this.paletteId,
      progressive: progressive ?? this.progressive,
      progressiveEvery: progressiveEvery ?? this.progressiveEvery,
      sortOrder: sortOrder ?? this.sortOrder,
      ambient: ambient ?? this.ambient,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'pattern': pattern.toMap(),
        'targetMinutes': targetMinutes,
        'targetCycles': targetCycles,
        'isBuiltIn': isBuiltIn,
        'isFavorite': isFavorite,
        'category': categoryIndex,
        'paletteId': paletteId,
        'progressive': progressive,
        'progressiveEvery': progressiveEvery,
        'sortOrder': sortOrder,
        'ambient': ambient,
      };

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Untitled',
        description: json['description'] as String? ?? '',
        pattern: BreathPattern.fromMap(
          (json['pattern'] as Map?) ?? const <String, dynamic>{},
        ),
        targetMinutes: (json['targetMinutes'] as num?)?.round() ?? 5,
        targetCycles: (json['targetCycles'] as num?)?.round(),
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        isFavorite: json['isFavorite'] as bool? ?? false,
        categoryIndex: (json['category'] as num?)?.round() ?? 4,
        paletteId: json['paletteId'] as String?,
        progressive: json['progressive'] as bool? ?? false,
        progressiveEvery: (json['progressiveEvery'] as num?)?.round() ?? 5,
        sortOrder: (json['sortOrder'] as num?)?.round() ?? 0,
        ambient: json['ambient'] as String? ?? 'none',
      );
}

class PresetAdapter extends TypeAdapter<Preset> {
  @override
  final int typeId = 1;

  @override
  Preset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preset(
      id: fields[0] as String? ?? 'preset_${DateTime.now().millisecondsSinceEpoch}',
      name: fields[1] as String? ?? 'Untitled',
      description: fields[2] as String? ?? '',
      pattern: fields[3] as BreathPattern? ?? BreathPattern.box,
      targetMinutes: (fields[4] as num?)?.round() ?? 5,
      targetCycles: (fields[5] as num?)?.round(),
      isBuiltIn: fields[6] as bool? ?? false,
      isFavorite: fields[7] as bool? ?? false,
      categoryIndex: (fields[8] as num?)?.round() ?? 4,
      paletteId: fields[9] as String?,
      progressive: fields[10] as bool? ?? false,
      progressiveEvery: (fields[11] as num?)?.round() ?? 5,
      sortOrder: (fields[12] as num?)?.round() ?? 0,
      ambient: fields[13] as String? ?? 'none',
    );
  }

  @override
  void write(BinaryWriter writer, Preset obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.pattern)
      ..writeByte(4)
      ..write(obj.targetMinutes)
      ..writeByte(5)
      ..write(obj.targetCycles)
      ..writeByte(6)
      ..write(obj.isBuiltIn)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.categoryIndex)
      ..writeByte(9)
      ..write(obj.paletteId)
      ..writeByte(10)
      ..write(obj.progressive)
      ..writeByte(11)
      ..write(obj.progressiveEvery)
      ..writeByte(12)
      ..write(obj.sortOrder)
      ..writeByte(13)
      ..write(obj.ambient);
  }
}

class BreathPatternAdapter extends TypeAdapter<BreathPattern> {
  @override
  final int typeId = 2;

  @override
  BreathPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathPattern(
      inhale: (fields[0] as num?)?.round() ?? 4,
      hold1: (fields[1] as num?)?.round() ?? 4,
      exhale: (fields[2] as num?)?.round() ?? 4,
      hold2: (fields[3] as num?)?.round() ?? 4,
    );
  }

  @override
  void write(BinaryWriter writer, BreathPattern obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.inhale)
      ..writeByte(1)
      ..write(obj.hold1)
      ..writeByte(2)
      ..write(obj.exhale)
      ..writeByte(3)
      ..write(obj.hold2);
  }
}
