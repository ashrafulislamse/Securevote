import 'package:freezed_annotation/freezed_annotation.dart';

part 'election.freezed.dart';
part 'election.g.dart';

/// A voting election (e.g. a country, state, or school election).
///
/// `type` and `status` are intentionally kept as free-form strings for now so
/// the model tolerates backend values that are still evolving. Strongly-typed
/// enums can be introduced once the backend contract is finalized.
@freezed
abstract class Election with _$Election {
  const factory Election({
    required String id,
    required String title,
    String? description,
    String? organization,
    @Default('general') String type,
    @Default('upcoming') String status,
    required DateTime startsAt,
    required DateTime endsAt,
    int? candidateCount,
  }) = _Election;

  factory Election.fromJson(Map<String, dynamic> json) =>
      _$ElectionFromJson(json);
}