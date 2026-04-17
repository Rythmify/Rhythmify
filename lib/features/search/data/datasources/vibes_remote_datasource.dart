import '../../domain/entities/vibes_category.dart';
import 'package:dio/dio.dart';
import '../models/vibes_dto.dart';
import 'dart:developer' as dev;

/// Contract for the vibes/categories remote data source.
abstract class VibesRemoteSource {
  /// Returns the list of all vibe categories shown in the vibes grid.
  Future<List<VibeCategory>> getVibes();
}

/// Real HTTP implementation of [VibesRemoteSource].

class VibesRemoteSourceImpl implements VibesRemoteSource {
  VibesRemoteSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<VibeCategory>> getVibes() async {
    final response = await _dio.get('/genres');
    dev.log('vibes grid response: ${response.data}');
    return VibesDto.parseVibeCategoryList(
      response.data as Map<String, dynamic>,
    );
  }
}
