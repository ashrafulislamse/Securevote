class ReceiptVerification {
  final bool valid;
  final String receiptId;
  final String? electionId;
  final String? electionTitle;
  final String? electionOrganization;
  final String? voteHash;
  final String? txHash;
  final int? blockNumber;
  final List<String> merkleProof;
  final String? merkleRoot;
  final String? finalizeTxHash;
  final int? finalizedAt;
  final int? verifiedAt;
  final int? createdAt;

  ReceiptVerification({
    required this.valid,
    required this.receiptId,
    this.electionId,
    this.electionTitle,
    this.electionOrganization,
    this.voteHash,
    this.txHash,
    this.blockNumber,
    this.merkleProof = const [],
    this.merkleRoot,
    this.finalizeTxHash,
    this.finalizedAt,
    this.verifiedAt,
    this.createdAt,
  });

  factory ReceiptVerification.fromJson(Map<String, dynamic> json) {
    final onchain = json['onchain'] as Map<String, dynamic>? ?? {};
    final proof = json['merkleProof'] as List<dynamic>? ?? [];
    return ReceiptVerification(
      valid: json['valid'] as bool? ?? false,
      receiptId: json['receiptId'] as String? ?? '',
      electionId: json['electionId'] as String?,
      electionTitle: json['electionTitle'] as String?,
      electionOrganization: json['electionOrganization'] as String?,
      voteHash: json['voteHash'] as String?,
      txHash: json['txHash'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
      merkleProof: proof.map((e) => e as String).toList(),
      merkleRoot: onchain['merkleRoot'] as String?,
      finalizeTxHash: onchain['finalizeTxHash'] as String?,
      finalizedAt: (onchain['finalizedAt'] as num?)?.toInt(),
      verifiedAt: (json['verifiedAt'] as num?)?.toInt(),
      createdAt: (json['createdAt'] as num?)?.toInt(),
    );
  }
}
