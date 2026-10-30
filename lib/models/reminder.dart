import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

@HiveType(typeId: 4)
class Reminder extends HiveObject {
  Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.label = 'Time to breathe',
    this.message = 'A few calm minutes can change the shape of your day.',
    this.enabled = true,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  List<int> weekdays;

  @HiveField(4)
  String label;

  @HiveField(5)
  String message;

  @HiveField(6)
  bool enabled;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m ${hour < 12 ? 'AM' : 'PM'}';
  }

  String get daysLabel {
    if (weekdays.length == 7) return 'Every day';
    if (weekdays.isEmpty) return 'No days selected';
    final sorted = [...weekdays]..sort();
    return sorted.map((d) => weekdayShort[d % 7]).join(', ');
  }

  List<int> get notificationIds =>
      weekdays.map((d) => (id.hashCode ^ (d * 97)) & 0x7fffffff).toList();

  Reminder copyWith({
    int? hour,
    int? minute,
    List<int>? weekdays,
    String? label,
    String? message,
    bool? enabled,
  }) {
    return Reminder(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      label: label ?? this.label,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 4;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      hour: fields[1] as int? ?? 8,
      minute: fields[2] as int? ?? 0,
      weekdays: (fields[3] as List?)?.cast<int>() ?? [0, 1, 2, 3, 4, 5, 6],
      label: fields[4] as String? ?? 'Time to breathe',
      message: fields[5] as String? ?? 'A few calm minutes can change the shape of your day.',
      enabled: fields[6] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.weekdays)
      ..writeByte(4)
      ..write(obj.label)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.enabled);
  }
}
