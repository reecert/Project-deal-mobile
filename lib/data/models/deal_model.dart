// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_model.freezed.dart';
part 'deal_model.g.dart';

@freezed
class DealModel with _$DealModel {
  const factory DealModel({
    required String id,
    required String title,
    @JsonKey(name: 'price_current') required double priceCurrent,
    @JsonKey(name: 'price_mrp') required double priceMrp,
    @JsonKey(name: 'deal_url') required String dealUrl,
    @Default([]) List<String> images,
    @JsonKey(name: 'store_name') required String storeName,
    String? category,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'upvote_count') @Default(0) int upvoteCount,
    @JsonKey(name: 'downvote_count') @Default(0) int downvoteCount,
    @Default(0) int score,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? slug,
    int? views,
    ProfileModel? profiles,
    // Aggregated from join
    @JsonKey(name: 'comment_count') int? commentCount,
    // User-specific (fetched separately)
    int? userVote,
    @Default(false) bool isSaved,
  }) = _DealModel;

  factory DealModel.fromJson(Map<String, dynamic> json) =>
      _$DealModelFromJson(json);
}

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    int? points,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

// Extension for computed properties
extension DealModelExt on DealModel {
  String get imageUrl => images.isNotEmpty
      ? images.first
      : 'https://placehold.co/400x400/png?text=No+Image';
  List<String> get galleryUrls => images.length > 1 ? images.sublist(1) : [];
  double get discountPercent =>
      priceMrp > 0 ? ((priceMrp - priceCurrent) / priceMrp * 100) : 0;
  String get authorUsername => profiles?.username ?? 'Anonymous';
  String get authorAvatarUrl => profiles?.avatarUrl ?? '';
}
