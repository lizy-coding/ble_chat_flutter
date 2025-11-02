/// Base exception thrown when a value object fails validation.
class ValidationException implements Exception {
  ValidationException(this.message);

  /// Description of the validation failure.
  final String message;

  @override
  String toString() => 'ValidationException: ' + message;
}

/// Thrown when a chat message payload is either empty or exceeds the
/// supported number of bytes for a BLE characteristic write.
class MessagePayloadException extends ValidationException {
  MessagePayloadException(String message) : super(message);
}
