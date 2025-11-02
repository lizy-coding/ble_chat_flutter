// GENERATED CODE - MANUALLY WRITTEN FOR TESTING

part of 'ble_device.dart';

BleDevice _$BleDeviceFromJson(Map<String, dynamic> json) => BleDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      lastRssi: json['lastRssi'] as int?,
      lastSeenAt: json['lastSeenAt'] == null
          ? null
          : DateTime.parse(json['lastSeenAt'] as String),
      isConnected: json['isConnected'] as bool? ?? false,
    );

Map<String, dynamic> _$BleDeviceToJson(BleDevice instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lastRssi': instance.lastRssi,
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'isConnected': instance.isConnected,
    };
