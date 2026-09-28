// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_alert_queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedAlertAdapter extends TypeAdapter<QueuedAlert> {
  @override
  final int typeId = 0;

  @override
  QueuedAlert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedAlert(
      id: fields[0] as String,
      userName: fields[1] as String,
      phone: fields[2] as String,
      latitude: fields[3] as double?,
      longitude: fields[4] as double?,
      startedAt: fields[5] as int,
      guardianNumbers: (fields[6] as List).cast<String>(),
      smsMessage: fields[9] as String,
      synced: fields[7] as bool,
      pendingSmsNumbers: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, QueuedAlert obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.guardianNumbers)
      ..writeByte(7)
      ..write(obj.synced)
      ..writeByte(8)
      ..write(obj.pendingSmsNumbers)
      ..writeByte(9)
      ..write(obj.smsMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedAlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
