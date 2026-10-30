import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class SessionRecord {
  SessionRecord({
    required this.id,
    required this.startedAt,
    required this.durationSec,
    required this.cyclesDone,
    required this.presetId,
    required this.presetName,
    required this.completed,
    this.moodAfter,
    this.patternLabel = '4 · 4 · 4 · 4',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startedAt;

  @HiveField(2)
  final int durationSec;

  @HiveField(3)
  final int cyclesDone;

  @HiveField(4)
  final String presetId;

  @HiveField(5)
  final String presetName;

  @HiveField(6)
  final bool completed;

  @HiveField(7)
  int? moodAfter;

  @HiveField(8)
  final String patternLabel;

  int get durationMinutes => (durationSec / 60).ceil();

  double get avgBreathSeconds =>
      cyclesDone == 0 ? 0 : durationSec / cyclesDone;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'durationSec': durationSec,
        'cyclesDone': cyclesDone,
        'presetId': presetId,
        'presetName': presetName,
        'completed': completed,
        'moodAfter': moodAfter,
        'patternLabel': patternLabel,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        durationSec: (json['durationSec'] as num).round(),
        cyclesDone: (json['cyclesDone'] as num).round(),
        presetId: json['presetId'] as String? ?? 'custom',
        presetName: json['presetName'] as String? ?? 'Breath',
        completed: json['completed'] as bool? ?? false,
        moodAfter: (json['moodAfter'] as num?)?.round(),
        patternLabel: json['patternLabel'] as String? ?? '4 · 4 · 4 · 4',
      );
}

class SessionRecordAdapter extends TypeAdapter<SessionRecord> {
  @override
  final int typeId = 3;

  @override
  SessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionRecord(
      id: fields[0] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      durationSec: fields[2] as int,
      cyclesDone: fields[3] as int,
      presetId: fields[4] as String? ?? 'custom',
      presetName: fields[5] as String? ?? 'Breath',
      completed: fields[6] as bool? ?? false,
      moodAfter: fields[7] as int?,
      patternLabel: fields[8] as String? ?? '4 · 4 · 4 · 4',
    );
  }

  @override
  void write(BinaryWriter writer, SessionRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startedAt.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.durationSec)
      ..writeByte(3)
      ..write(obj.cyclesDone)
      ..writeByte(4)
      ..write(obj.presetId)
      ..writeByte(5)
      ..write(obj.presetName)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.moodAfter)
      ..writeByte(8)
      ..write(obj.patternLabel);
  }
}
