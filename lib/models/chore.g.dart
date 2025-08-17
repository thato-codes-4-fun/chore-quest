// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chore.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChoreAdapter extends TypeAdapter<Chore> {
  @override
  final int typeId = 3;

  @override
  Chore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chore(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      value: fields[3] as double,
      assigneeId: fields[4] as String,
      assignedById: fields[5] as String,
      status: fields[6] as ChoreStatus,
      assignedAt: fields[7] as DateTime,
      completedAt: fields[8] as DateTime?,
      approvedAt: fields[9] as DateTime?,
      proofImageUrl: fields[10] as String?,
      notes: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Chore obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.assigneeId)
      ..writeByte(5)
      ..write(obj.assignedById)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.assignedAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.approvedAt)
      ..writeByte(10)
      ..write(obj.proofImageUrl)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChoreStatusAdapter extends TypeAdapter<ChoreStatus> {
  @override
  final int typeId = 2;

  @override
  ChoreStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChoreStatus.assigned;
      case 1:
        return ChoreStatus.completed;
      case 2:
        return ChoreStatus.approved;
      case 3:
        return ChoreStatus.rejected;
      default:
        return ChoreStatus.assigned;
    }
  }

  @override
  void write(BinaryWriter writer, ChoreStatus obj) {
    switch (obj) {
      case ChoreStatus.assigned:
        writer.writeByte(0);
        break;
      case ChoreStatus.completed:
        writer.writeByte(1);
        break;
      case ChoreStatus.approved:
        writer.writeByte(2);
        break;
      case ChoreStatus.rejected:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoreStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
