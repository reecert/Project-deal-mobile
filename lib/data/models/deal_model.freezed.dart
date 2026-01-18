// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DealModel _$DealModelFromJson(Map<String, dynamic> json) {
  return _DealModel.fromJson(json);
}

/// @nodoc
mixin _$DealModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_current')
  double get priceCurrent => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_mrp')
  double get priceMrp => throw _privateConstructorUsedError;
  @JsonKey(name: 'deal_url')
  String get dealUrl => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_name')
  String get storeName => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'upvote_count')
  int get upvoteCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'downvote_count')
  int get downvoteCount => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  int? get views => throw _privateConstructorUsedError;
  ProfileModel? get profiles =>
      throw _privateConstructorUsedError; // Aggregated from join
  @JsonKey(name: 'comment_count')
  int? get commentCount =>
      throw _privateConstructorUsedError; // User-specific (fetched separately)
  int? get userVote => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DealModelCopyWith<DealModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealModelCopyWith<$Res> {
  factory $DealModelCopyWith(DealModel value, $Res Function(DealModel) then) =
      _$DealModelCopyWithImpl<$Res, DealModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'price_current') double priceCurrent,
      @JsonKey(name: 'price_mrp') double priceMrp,
      @JsonKey(name: 'deal_url') String dealUrl,
      List<String> images,
      @JsonKey(name: 'store_name') String storeName,
      String? category,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'upvote_count') int upvoteCount,
      @JsonKey(name: 'downvote_count') int downvoteCount,
      int score,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? slug,
      int? views,
      ProfileModel? profiles,
      @JsonKey(name: 'comment_count') int? commentCount,
      int? userVote,
      bool isSaved});

  $ProfileModelCopyWith<$Res>? get profiles;
}

/// @nodoc
class _$DealModelCopyWithImpl<$Res, $Val extends DealModel>
    implements $DealModelCopyWith<$Res> {
  _$DealModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? priceCurrent = null,
    Object? priceMrp = null,
    Object? dealUrl = null,
    Object? images = null,
    Object? storeName = null,
    Object? category = freezed,
    Object? isVerified = null,
    Object? upvoteCount = null,
    Object? downvoteCount = null,
    Object? score = null,
    Object? createdAt = null,
    Object? slug = freezed,
    Object? views = freezed,
    Object? profiles = freezed,
    Object? commentCount = freezed,
    Object? userVote = freezed,
    Object? isSaved = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      priceCurrent: null == priceCurrent
          ? _value.priceCurrent
          : priceCurrent // ignore: cast_nullable_to_non_nullable
              as double,
      priceMrp: null == priceMrp
          ? _value.priceMrp
          : priceMrp // ignore: cast_nullable_to_non_nullable
              as double,
      dealUrl: null == dealUrl
          ? _value.dealUrl
          : dealUrl // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      upvoteCount: null == upvoteCount
          ? _value.upvoteCount
          : upvoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      downvoteCount: null == downvoteCount
          ? _value.downvoteCount
          : downvoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      profiles: freezed == profiles
          ? _value.profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as ProfileModel?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      userVote: freezed == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int?,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProfileModelCopyWith<$Res>? get profiles {
    if (_value.profiles == null) {
      return null;
    }

    return $ProfileModelCopyWith<$Res>(_value.profiles!, (value) {
      return _then(_value.copyWith(profiles: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DealModelImplCopyWith<$Res>
    implements $DealModelCopyWith<$Res> {
  factory _$$DealModelImplCopyWith(
          _$DealModelImpl value, $Res Function(_$DealModelImpl) then) =
      __$$DealModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'price_current') double priceCurrent,
      @JsonKey(name: 'price_mrp') double priceMrp,
      @JsonKey(name: 'deal_url') String dealUrl,
      List<String> images,
      @JsonKey(name: 'store_name') String storeName,
      String? category,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'upvote_count') int upvoteCount,
      @JsonKey(name: 'downvote_count') int downvoteCount,
      int score,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? slug,
      int? views,
      ProfileModel? profiles,
      @JsonKey(name: 'comment_count') int? commentCount,
      int? userVote,
      bool isSaved});

  @override
  $ProfileModelCopyWith<$Res>? get profiles;
}

/// @nodoc
class __$$DealModelImplCopyWithImpl<$Res>
    extends _$DealModelCopyWithImpl<$Res, _$DealModelImpl>
    implements _$$DealModelImplCopyWith<$Res> {
  __$$DealModelImplCopyWithImpl(
      _$DealModelImpl _value, $Res Function(_$DealModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? priceCurrent = null,
    Object? priceMrp = null,
    Object? dealUrl = null,
    Object? images = null,
    Object? storeName = null,
    Object? category = freezed,
    Object? isVerified = null,
    Object? upvoteCount = null,
    Object? downvoteCount = null,
    Object? score = null,
    Object? createdAt = null,
    Object? slug = freezed,
    Object? views = freezed,
    Object? profiles = freezed,
    Object? commentCount = freezed,
    Object? userVote = freezed,
    Object? isSaved = null,
  }) {
    return _then(_$DealModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      priceCurrent: null == priceCurrent
          ? _value.priceCurrent
          : priceCurrent // ignore: cast_nullable_to_non_nullable
              as double,
      priceMrp: null == priceMrp
          ? _value.priceMrp
          : priceMrp // ignore: cast_nullable_to_non_nullable
              as double,
      dealUrl: null == dealUrl
          ? _value.dealUrl
          : dealUrl // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      upvoteCount: null == upvoteCount
          ? _value.upvoteCount
          : upvoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      downvoteCount: null == downvoteCount
          ? _value.downvoteCount
          : downvoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      profiles: freezed == profiles
          ? _value.profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as ProfileModel?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      userVote: freezed == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int?,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealModelImpl implements _DealModel {
  const _$DealModelImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'price_current') required this.priceCurrent,
      @JsonKey(name: 'price_mrp') required this.priceMrp,
      @JsonKey(name: 'deal_url') required this.dealUrl,
      final List<String> images = const [],
      @JsonKey(name: 'store_name') required this.storeName,
      this.category,
      @JsonKey(name: 'is_verified') this.isVerified = false,
      @JsonKey(name: 'upvote_count') this.upvoteCount = 0,
      @JsonKey(name: 'downvote_count') this.downvoteCount = 0,
      this.score = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.slug,
      this.views,
      this.profiles,
      @JsonKey(name: 'comment_count') this.commentCount,
      this.userVote,
      this.isSaved = false})
      : _images = images;

  factory _$DealModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'price_current')
  final double priceCurrent;
  @override
  @JsonKey(name: 'price_mrp')
  final double priceMrp;
  @override
  @JsonKey(name: 'deal_url')
  final String dealUrl;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey(name: 'store_name')
  final String storeName;
  @override
  final String? category;
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @override
  @JsonKey(name: 'upvote_count')
  final int upvoteCount;
  @override
  @JsonKey(name: 'downvote_count')
  final int downvoteCount;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String? slug;
  @override
  final int? views;
  @override
  final ProfileModel? profiles;
// Aggregated from join
  @override
  @JsonKey(name: 'comment_count')
  final int? commentCount;
// User-specific (fetched separately)
  @override
  final int? userVote;
  @override
  @JsonKey()
  final bool isSaved;

  @override
  String toString() {
    return 'DealModel(id: $id, title: $title, priceCurrent: $priceCurrent, priceMrp: $priceMrp, dealUrl: $dealUrl, images: $images, storeName: $storeName, category: $category, isVerified: $isVerified, upvoteCount: $upvoteCount, downvoteCount: $downvoteCount, score: $score, createdAt: $createdAt, slug: $slug, views: $views, profiles: $profiles, commentCount: $commentCount, userVote: $userVote, isSaved: $isSaved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.priceCurrent, priceCurrent) ||
                other.priceCurrent == priceCurrent) &&
            (identical(other.priceMrp, priceMrp) ||
                other.priceMrp == priceMrp) &&
            (identical(other.dealUrl, dealUrl) || other.dealUrl == dealUrl) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.upvoteCount, upvoteCount) ||
                other.upvoteCount == upvoteCount) &&
            (identical(other.downvoteCount, downvoteCount) ||
                other.downvoteCount == downvoteCount) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.profiles, profiles) ||
                other.profiles == profiles) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.userVote, userVote) ||
                other.userVote == userVote) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        priceCurrent,
        priceMrp,
        dealUrl,
        const DeepCollectionEquality().hash(_images),
        storeName,
        category,
        isVerified,
        upvoteCount,
        downvoteCount,
        score,
        createdAt,
        slug,
        views,
        profiles,
        commentCount,
        userVote,
        isSaved
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DealModelImplCopyWith<_$DealModelImpl> get copyWith =>
      __$$DealModelImplCopyWithImpl<_$DealModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealModelImplToJson(
      this,
    );
  }
}

abstract class _DealModel implements DealModel {
  const factory _DealModel(
      {required final String id,
      required final String title,
      @JsonKey(name: 'price_current') required final double priceCurrent,
      @JsonKey(name: 'price_mrp') required final double priceMrp,
      @JsonKey(name: 'deal_url') required final String dealUrl,
      final List<String> images,
      @JsonKey(name: 'store_name') required final String storeName,
      final String? category,
      @JsonKey(name: 'is_verified') final bool isVerified,
      @JsonKey(name: 'upvote_count') final int upvoteCount,
      @JsonKey(name: 'downvote_count') final int downvoteCount,
      final int score,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final String? slug,
      final int? views,
      final ProfileModel? profiles,
      @JsonKey(name: 'comment_count') final int? commentCount,
      final int? userVote,
      final bool isSaved}) = _$DealModelImpl;

  factory _DealModel.fromJson(Map<String, dynamic> json) =
      _$DealModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'price_current')
  double get priceCurrent;
  @override
  @JsonKey(name: 'price_mrp')
  double get priceMrp;
  @override
  @JsonKey(name: 'deal_url')
  String get dealUrl;
  @override
  List<String> get images;
  @override
  @JsonKey(name: 'store_name')
  String get storeName;
  @override
  String? get category;
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;
  @override
  @JsonKey(name: 'upvote_count')
  int get upvoteCount;
  @override
  @JsonKey(name: 'downvote_count')
  int get downvoteCount;
  @override
  int get score;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String? get slug;
  @override
  int? get views;
  @override
  ProfileModel? get profiles;
  @override // Aggregated from join
  @JsonKey(name: 'comment_count')
  int? get commentCount;
  @override // User-specific (fetched separately)
  int? get userVote;
  @override
  bool get isSaved;
  @override
  @JsonKey(ignore: true)
  _$$DealModelImplCopyWith<_$DealModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) {
  return _ProfileModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileModel {
  String get id => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  int? get points => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
          ProfileModel value, $Res Function(ProfileModel) then) =
      _$ProfileModelCopyWithImpl<$Res, ProfileModel>;
  @useResult
  $Res call(
      {String id,
      String? username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      int? points});
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res, $Val extends ProfileModel>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = freezed,
    Object? avatarUrl = freezed,
    Object? points = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: freezed == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileModelImplCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$$ProfileModelImplCopyWith(
          _$ProfileModelImpl value, $Res Function(_$ProfileModelImpl) then) =
      __$$ProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      int? points});
}

/// @nodoc
class __$$ProfileModelImplCopyWithImpl<$Res>
    extends _$ProfileModelCopyWithImpl<$Res, _$ProfileModelImpl>
    implements _$$ProfileModelImplCopyWith<$Res> {
  __$$ProfileModelImplCopyWithImpl(
      _$ProfileModelImpl _value, $Res Function(_$ProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = freezed,
    Object? avatarUrl = freezed,
    Object? points = freezed,
  }) {
    return _then(_$ProfileModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: freezed == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileModelImpl implements _ProfileModel {
  const _$ProfileModelImpl(
      {required this.id,
      this.username,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.points});

  factory _$ProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? username;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final int? points;

  @override
  String toString() {
    return 'ProfileModel(id: $id, username: $username, avatarUrl: $avatarUrl, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, avatarUrl, points);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      __$$ProfileModelImplCopyWithImpl<_$ProfileModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileModelImplToJson(
      this,
    );
  }
}

abstract class _ProfileModel implements ProfileModel {
  const factory _ProfileModel(
      {required final String id,
      final String? username,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final int? points}) = _$ProfileModelImpl;

  factory _ProfileModel.fromJson(Map<String, dynamic> json) =
      _$ProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get username;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  int? get points;
  @override
  @JsonKey(ignore: true)
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
