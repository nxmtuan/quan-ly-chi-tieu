String generateLocalEntityId() {
  return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
