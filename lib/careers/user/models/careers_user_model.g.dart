// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'careers_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareersUserModelAdapter extends TypeAdapter<CareersUserModel> {
  @override
  final int typeId = 10;

  @override
  CareersUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareersUserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String?,
      profileImage: fields[4] as String?,
      resumeUrl: fields[5] as String?,
      skills: (fields[6] as List).cast<String>(),
      preferredLocation: fields[7] as String?,
      experienceLevel: fields[8] as String?,
      preferredSchoolIds: (fields[9] as List).cast<int>(),
      lastLoginAt: fields[10] as DateTime?,
      isProfileComplete: fields[11] as bool,
      preferences: (fields[12] as Map).cast<String, dynamic>(),
      sessionToken: fields[13] as String?,
      nationality: fields[14] as String?,
      location: fields[15] as String?,
      isEmailVerified: fields[16] as bool,
      verificationToken: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CareersUserModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profileImage)
      ..writeByte(5)
      ..write(obj.resumeUrl)
      ..writeByte(6)
      ..write(obj.skills)
      ..writeByte(7)
      ..write(obj.preferredLocation)
      ..writeByte(8)
      ..write(obj.experienceLevel)
      ..writeByte(9)
      ..write(obj.preferredSchoolIds)
      ..writeByte(10)
      ..write(obj.lastLoginAt)
      ..writeByte(11)
      ..write(obj.isProfileComplete)
      ..writeByte(12)
      ..write(obj.preferences)
      ..writeByte(13)
      ..write(obj.sessionToken)
      ..writeByte(14)
      ..write(obj.nationality)
      ..writeByte(15)
      ..write(obj.location)
      ..writeByte(16)
      ..write(obj.isEmailVerified)
      ..writeByte(17)
      ..write(obj.verificationToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareersUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
