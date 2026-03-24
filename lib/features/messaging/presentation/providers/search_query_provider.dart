import 'package:flutter_riverpod/legacy.dart';

/// Provider that manages the current search query string.
///
/// This state is typically updated by a search bar and watched by
/// providers that perform user searches.
final queryProvider = StateProvider<String>((ref) => '');
