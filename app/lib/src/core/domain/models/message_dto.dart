import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

enum MessageDirection { in_, out }

enum MessageStatus { sending, sent, delivered }

@JsonSerializable()
class MessageDto {
  final String id;
  final String peerId;
  final MessageDirection direction;
  final String text;
  final DateTime ts;
  final MessageStatus status;

  MessageDto({
    required this.id,
    required this.peerId,
    required this.direction,
    required this.text,
    DateTime? ts,
    this.status = MessageStatus.delivered,
  }) : ts = ts ?? DateTime.now();

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

