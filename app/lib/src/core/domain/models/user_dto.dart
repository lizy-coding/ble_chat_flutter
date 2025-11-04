import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String uid;
  final String? nickname;
  final DateTime createdAt;

  UserDto({
    required this.uid,
    this.nickname,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

