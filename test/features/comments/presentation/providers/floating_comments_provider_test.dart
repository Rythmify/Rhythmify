import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/domain/usecases/get_floating_comments_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/comments/presentation/providers/floating_comments_provider.dart';

class MockGetFloatingCommentsUseCase extends Mock implements GetFloatingCommentsUseCase {}

void main() {
  late ProviderContainer container;
  late MockGetFloatingCommentsUseCase mockGetFloatingComments;

  setUp(() {
    mockGetFloatingComments = MockGetFloatingCommentsUseCase();

    container = ProviderContainer(
      overrides: [
        getFloatingCommentsProvider.overrideWithValue(mockGetFloatingComments),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('floatingCommentsProvider fetches and caches data', () async {
    final tMap = {
      45: (pfp: 'https://example.com/pfp.png', text: 'Nice!'),
    };

    when(() => mockGetFloatingComments(any())).thenAnswer((_) async => tMap);

    final result = await container.read(floatingCommentsProvider('track-456').future);

    expect(result, tMap);
    verify(() => mockGetFloatingComments('track-456')).called(1);
  });
}
