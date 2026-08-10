/// Identity-verification status for a user.
///
/// Serialized by name by `json_serializable` (matches the API's lowercase
/// values `pending`, `approved`, `rejected`). `notSubmitted` is a local
/// fallback used when the value is absent or unknown.
enum KycStatus {
  notSubmitted,
  pending,
  approved,
  rejected;

  /// Parses a raw API value into a [KycStatus], defaulting to
  /// [KycStatus.notSubmitted] for unknown/empty values.
  static KycStatus parse(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return KycStatus.pending;
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      default:
        return KycStatus.notSubmitted;
    }
  }
}