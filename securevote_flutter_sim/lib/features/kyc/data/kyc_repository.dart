import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/models/kyc_status.dart';
import '../../../core/network/api_client.dart';

/// Data access for identity verification (KYC).
class KycRepository {
  KycRepository({ApiClient? api}) : _api = api ?? ApiClient.instance;

  final ApiClient _api;

  /// Submits an identity document for review.
  ///
  /// Backend: `POST /api/kyc/submit` expects multipart form-data with a
  /// `file` field and an optional `docType` field (`id` | `selfie`).
  Future<void> submitDocument({
    required Uint8List bytes,
    required String fileName,
    String docType = 'id',
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'docType': docType,
    });
    await _api.dio.post('/api/kyc/submit', data: form);
  }

  /// Fetches the current user's KYC verification status.
  ///
  /// Backend: `GET /api/kyc/status` returns `{ status: 'pending'|'approved'|'rejected' }`.
  Future<KycStatus> getStatus() async {
    final data = await _api.getApi('/api/kyc/status') as Map<String, dynamic>;
    return KycStatus.parse(data['status'] as String?);
  }
}