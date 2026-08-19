import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/kyc_document.dart';
import '../../../core/models/kyc_status.dart';
import '../../../core/network/api_client.dart';

/// Data access for identity verification (KYC).
class KycRepository {
  KycRepository({ApiClient? api, ImagePicker? picker})
    : _api = api ?? ApiClient.instance,
      _picker = picker ?? ImagePicker();

  final ApiClient _api;
  final ImagePicker _picker;

  /// Submits an identity document for review.
  ///
  /// Backend: `POST /api/kyc/submit` expects multipart form-data with a
  /// `file` field and an optional `docType` field (`id` | `selfie`).
  Future<KycDocument> submitDocument({
    required Uint8List bytes,
    required String fileName,
    String docType = 'id',
  }) async {
    final form = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'docType': docType,
    });
    final data = await _api.postApi('/api/kyc/submit', data: form);
    if (data is Map<String, dynamic>) {
      final doc = data['document'];
      if (doc is Map<String, dynamic>) {
        return KycDocument.fromJson(<String, dynamic>{
          'id': doc['id'] as String? ?? '',
          'docType': docType,
          'status': doc['status'] as String? ?? 'pending',
        });
      }
    }
    return KycDocument(id: '', docType: docType, status: 'pending');
  }

  /// Fetches the current user's KYC verification status.
  ///
  /// Backend: `GET /api/kyc/status` returns
  /// `{ status, documents: [{ id, doc_type, status, created_at }] }`.
  Future<KycStatusSnapshot> getStatus() async {
    final data = await _api.getApi('/api/kyc/status') as Map<String, dynamic>;
    final status = KycStatus.parse(data['status'] as String?);
    final rawDocs = data['documents'];
    final List<KycDocument> documents;
    if (rawDocs is List) {
      documents = rawDocs
          .whereType<Map<String, dynamic>>()
          .map(KycDocument.fromJson)
          .toList();
    } else {
      documents = const <KycDocument>[];
    }
    return KycStatusSnapshot(status: status, documents: documents);
  }

  /// Fetches the documents the current user has previously submitted.
  Future<List<KycDocument>> getDocuments() async {
    final snapshot = await getStatus();
    return snapshot.documents;
  }

  /// Opens the system camera (with a gallery fallback) to pick an image for
  /// the given KYC [docType] (`id` or `selfie`).
  ///
  /// Returns the raw bytes of the picked image, or `null` if the user
  /// cancelled. Throws if neither camera nor gallery returned a usable file.
  Future<PickedKycImage?> pickImage({required String docType}) async {
    // Use the front camera for selfies/liveness, back camera for ID documents.
    final CameraDevice preferred =
        docType == 'selfie' ? CameraDevice.front : CameraDevice.rear;
    XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: preferred,
      imageQuality: 85,
      maxWidth: 2000,
    );
    file ??= await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (file == null) return null;
    final bytes = await _readFileBytes(file);
    return PickedKycImage(bytes: bytes, fileName: file.name, docType: docType);
  }

  /// Convenience that picks an image and submits it in a single call.
  /// Returns the resulting [KycDocument] on success or `null` if the user
  /// cancelled the picker.
  Future<KycDocument?> pickAndSubmit({required String docType}) async {
    final picked = await pickImage(docType: docType);
    if (picked == null) return null;
    return submitDocument(
      bytes: picked.bytes,
      fileName: picked.fileName,
      docType: docType,
    );
  }

  Future<Uint8List> _readFileBytes(XFile file) async {
    final ioFile = File(file.path);
    if (await ioFile.exists()) {
      return ioFile.readAsBytes();
    }
    return file.readAsBytes();
  }
}

/// Container for a freshly picked KYC image, including the raw bytes ready
/// to be uploaded to the backend.
class PickedKycImage {
  const PickedKycImage({
    required this.bytes,
    required this.fileName,
    required this.docType,
  });

  final Uint8List bytes;
  final String fileName;
  final String docType;
}

/// A snapshot of the current user's KYC submission: the aggregate
/// [KycStatus] plus the individual [KycDocument]s that have been uploaded.
class KycStatusSnapshot {
  const KycStatusSnapshot({required this.status, required this.documents});

  final KycStatus status;
  final List<KycDocument> documents;

  /// The most recent document of the given [docType], or null if none.
  KycDocument? latestOfType(String docType) {
    for (final doc in documents) {
      if (doc.docType == docType) return doc;
    }
    return null;
  }
}
