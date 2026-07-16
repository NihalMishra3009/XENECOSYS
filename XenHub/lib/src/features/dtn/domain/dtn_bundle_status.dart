enum DtnBundleStatus {
  queued,
  delivered;

  static DtnBundleStatus fromName(String name) {
    return DtnBundleStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => DtnBundleStatus.queued,
    );
  }
}
