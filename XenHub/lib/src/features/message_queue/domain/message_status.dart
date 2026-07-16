enum MessageStatus {
  queued,
  processing,
  sent,
  failed;

  static MessageStatus fromName(String name) {
    return MessageStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => MessageStatus.queued,
    );
  }
}
