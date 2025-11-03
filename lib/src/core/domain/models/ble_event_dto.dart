import 'package:json_annotation/json_annotation.dart';

part 'ble_event_dto.g.dart';

@JsonSerializable()
class BleEventDto {
  final String type; // scan_result | connected | disconnected | notify
  final String deviceId;
  final String? payload; // 文本行或状态
  final DateTime ts;

  BleEventDto({
    required this.type,
    required this.deviceId,
    this.payload,
    DateTime? ts,
  }) : ts = ts ?? DateTime.now();

  factory BleEventDto.fromJson(Map<String, dynamic> json) =>
      _$BleEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BleEventDtoToJson(this);
}
