import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'ble_device.g.dart';

/// Immutable snapshot of a BLE device that participates in the chat network.
@immutable
@JsonSerializable()
class BleDevice {
  const BleDevice({
    required this.id,
    required this.name,
    this.lastRssi,
    this.lastSeenAt,
    this.isConnected = false,
  });

  /// Unique identifier derived from the advertising payload.
  final String id;

  /// Friendly display name for the device.
  final String name;

  /// Most recent RSSI value captured for the device.
  final int? lastRssi;

  /// Timestamp of the last advertisement or interaction.
  final DateTime? lastSeenAt;

  /// Whether the device is currently connected to this client.
  final bool isConnected;

  /// Builds an instance from JSON.
  factory BleDevice.fromJson(Map<String, dynamic> json) =>
      _$BleDeviceFromJson(json);

  /// Serialises this device to JSON.
  Map<String, dynamic> toJson() => _$BleDeviceToJson(this);

  /// Returns a copy with updated fields.
  BleDevice copyWith({
    String? id,
    String? name,
    int? lastRssi,
    DateTime? lastSeenAt,
    bool? isConnected,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      lastRssi: lastRssi ?? this.lastRssi,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  /// Updates the signal strength while keeping the rest of the state intact.
  BleDevice updateSignal(int rssi, {DateTime? timestamp}) => copyWith(
        lastRssi: rssi,
        lastSeenAt: timestamp ?? DateTime.now(),
      );

  @override
  String toString() =>
      'BleDevice(id: $id, name: $name, rssi: $lastRssi, connected: $isConnected)';

  @override
  bool operator ==(Object other) {
    return other is BleDevice &&
        other.id == id &&
        other.name == name &&
        other.lastRssi == lastRssi &&
        other.lastSeenAt == lastSeenAt &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode => Object.hash(id, name, lastRssi, lastSeenAt, isConnected);
}
