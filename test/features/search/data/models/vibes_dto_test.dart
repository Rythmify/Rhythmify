import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/models/vibes_dto.dart';

void main() {
  group('VibesDto', () {
    test('parses a vibe category with cycled visuals', () {
      final category = VibesDto.parseVibeCategory({
        'id': 'pop',
        'name': 'Pop',
      }, 0);

      expect(category.id, 'pop');
      expect(category.title, 'Pop');
      expect(category.imagePath, 'assets/images/vibes_2.jpeg');
      expect(category.height, 150);
      expect(category.color, const Color(0xFF9C27B0));
    });

    test('cycles image, height, and color pools by index', () {
      final category = VibesDto.parseVibeCategory({
        'id': 'late',
        'name': 'Late Index',
      }, 10);

      expect(category.imagePath, 'assets/images/vibes_2.jpeg');
      expect(category.height, 250);
      expect(category.color, const Color(0xFF3F51B5));
    });

    test('parses category list from data array', () {
      final categories = VibesDto.parseVibeCategoryList({
        'data': [
          {'id': 'hiphop', 'name': 'Hip Hop'},
          {'id': 'electronic', 'name': 'Electronic'},
        ],
      });

      expect(categories, hasLength(2));
      expect(categories[0].id, 'hiphop');
      expect(categories[1].title, 'Electronic');
    });

    test('returns empty list when data is missing', () {
      final categories = VibesDto.parseVibeCategoryList({});

      expect(categories, isEmpty);
    });
  });
}
