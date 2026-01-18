// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DealModelImpl _$$DealModelImplFromJson(Map<String, dynamic> json) =>
    _$DealModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      priceCurrent: (json['price_current'] as num).toDouble(),
      priceMrp: (json['price_mrp'] as num).toDouble(),
      dealUrl: json['deal_url'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      storeName: json['store_name'] as String,
      category: json['category'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      upvoteCount: (json['upvote_count'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvote_count'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      slug: json['slug'] as String?,
      views: (json['views'] as num?)?.toInt(),
      profiles: json['profiles'] == null
          ? null
          : ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>),
      commentCount: (json['comment_count'] as num?)?.toInt(),
      userVote: (json['userVote'] as num?)?.toInt(),
      isSaved: json['isSaved'] as bool? ?? false,
    );

Map<String, dynamic> _$$DealModelImplToJson(_$DealModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price_current': instance.priceCurrent,
      'price_mrp': instance.priceMrp,
      'deal_url': instance.dealUrl,
      'images': instance.images,
      'store_name': instance.storeName,
      'category': instance.category,
      'is_verified': instance.isVerified,
      'upvote_count': instance.upvoteCount,
      'downvote_count': instance.downvoteCount,
      'score': instance.score,
      'created_at': instance.createdAt.toIso8601String(),
      'slug': instance.slug,
      'views': instance.views,
      'profiles': instance.profiles,
      'comment_count': instance.commentCount,
      'userVote': instance.userVote,
      'isSaved': instance.isSaved,
    };

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      points: (json['points'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'points': instance.points,
    };
