// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthModelAdapter extends TypeAdapter<AuthModel> {
  @override
  final int typeId = 0;

  @override
  AuthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthModel(
      schoolCode: fields[0] as String,
      id: fields[1] as int,
      userName: fields[2] as String,
      password: fields[3] as String,
      token: fields[4] as String,
      isActive: fields[5] as bool,
      profilePicture: fields[6] as String,
      designation: fields[7] as String,
      name: fields[8] as String,
      userId: fields[9] as String,
      notificationCount: fields[10] as int,
      logo: fields[11] as String,
      schoolName: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AuthModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.schoolCode)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.token)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.profilePicture)
      ..writeByte(7)
      ..write(obj.designation)
      ..writeByte(8)
      ..write(obj.name)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.notificationCount)
      ..writeByte(11)
      ..write(obj.logo)
      ..writeByte(12)
      ..write(obj.schoolName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
