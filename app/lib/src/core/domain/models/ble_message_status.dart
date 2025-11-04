/// Represents the high level delivery state of a BLE chat message.
enum BleMessageStatus {
  /// The message has been created locally but not acknowledged by the peer yet.
  pending,

  /// The peer has acknowledged the message but the user has not marked it as read.
  delivered,

  /// The peer has explicitly marked the message as read.
  read,
}

