import '../../../core/models/kyc_status.dart';
import '../../../core/network/api_client.dart';

/// Data access for identity verification (KYC).
///
/// NOTE: The backend does not expose these endpoints yet. These methods are
/// stubs that issue the intended HTTP calls and return placeholders so the
/// wiring is in place for a later phase.
class KycRepository {
  KycRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Submits identity documents for review.
  ///
  /// TODO(backend): implement once `POST /api/kyc/documents` is available.
  Future<void> submitDocuments({
    required List<String> documentUrls,
    required String documentType,
  }) async {
    await _api.postApi(
      '/api/kyc/documents',
      data: {
        'documentType': documentType,
        'documentUrls': documentUrls,
      },
    );
  }

  /// Fetches the current user's KYC verification status.
  ///
  /// TODO(backend): implement once `GET /api/kyc/status` is available.
  Future<KycStatus> getStatus() async {
    final data = await _api.getApi('/api/kyc/status');
    if (data is Map<String, dynamic>) {
      return KycStatus.parse(data['status'] as String?);
    }
    return KycStatus.notSubmitted;
  }
}