// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrape_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScrapeDataImpl _$$ScrapeDataImplFromJson(Map<String, dynamic> json) =>
    _$ScrapeDataImpl(
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      store: json['store'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ScrapeDataImplToJson(_$ScrapeDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'store': instance.store,
      'images': instance.images,
    };
