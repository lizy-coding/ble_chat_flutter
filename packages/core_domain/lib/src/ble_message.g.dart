// GENERATED CODE - MANUALLY WRITTEN FOR TESTING

part of 'ble_message.dart';

BleMessage _$BleMessageFromJson(Map<String, dynamic> json) {
  return BleMessage(
    id: json['id'] as String,
    conversationId: json['conversationId'] as String,
    senderDeviceId: json['senderDeviceId'] as String,
    receiverDeviceId: json['receiverDeviceId'] as String,
    payload: json['payload'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    deliveredAt: json['deliveredAt'] == null
        ? null
        : DateTime.parse(json['deliveredAt'] as String),
    readAt:
        json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
  );
}

Map<String, dynamic> _$BleMessageToJson(BleMessage instance) => <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderDeviceId': instance.senderDeviceId,
      'receiverDeviceId': instance.receiverDeviceId,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };
