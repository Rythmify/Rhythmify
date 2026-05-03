import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/data/datasources/api_endpoints.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_implement.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

/// Mock Dio client used to stub HTTP responses in [DatasourceImplement] tests.
class MockDio extends Mock implements Dio {}

/// Creates a successful [Response] wrapping [data] with HTTP 200.
Response<dynamic> _resp(dynamic data) => Response<dynamic>(
  data: data,
  statusCode: 200,
  requestOptions: RequestOptions(path: ''),
);

/// Creates a [DioException] with the given [statusCode] for error-path testing.
DioException _dioEx(int statusCode) => DioException(
  requestOptions: RequestOptions(path: ''),
  response: Response<dynamic>(
    statusCode: statusCode,
    requestOptions: RequestOptions(path: ''),
  ),
  type: DioExceptionType.badResponse,
);

/// Tests for [DatasourceImplement] — the Dio-backed HTTP datasource.
///
/// All HTTP calls are stubbed via [MockDio]. Covers response parsing for both
/// Map and List data shapes, pagination fallbacks, 409 swallowing in
/// [markMessagesAsRead], embed deduplication in [getEmbeds], artist-name
/// fallbacks in [getTrackDetails], and error propagation paths.
void main() {
  late MockDio mockDio;
  late DatasourceImplement ds;

  final tConvJson = {
    'id': 'c1',
    'participant': {'id': 'u2', 'display_name': 'Alice'},
    'last_message': {'body': 'Hey', 'created_at': '2024-01-01T00:00:00.000Z'},
    'unread_count': 0,
  };

  final tMsgJson = {
    'id': 'm1',
    'conversation_id': 'c1',
    'sender_id': 'u1',
    'body': 'Hello',
    'is_read': false,
    'created_at': '2024-01-01T00:00:00.000Z',
  };

  final tUserJson = {'id': 'u2', 'display_name': 'Alice'};

  setUp(() {
    mockDio = MockDio();
    ds = DatasourceImplement(dio: mockDio);
  });

  // ─── getConversations ────────────────────────────────────────────────────────

  group('getConversations', () {
    test('returns list of conversations on success', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'items': [tConvJson],
          },
        }),
      );

      final result = await ds.getConversations();

      expect(result, hasLength(1));
      expect(result.first.conversationId, 'c1');
      expect(result.first.participantName, 'Alice');
    });

    test('returns empty list when items is empty', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'items': []},
        }),
      );

      expect(await ds.getConversations(), isEmpty);
    });

    test('throws when response data is not a map', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _resp('bad'));

      expect(() => ds.getConversations(), throwsException);
    });
  });

  // ─── getMessages ─────────────────────────────────────────────────────────────

  group('getMessages', () {
    test('parses messages when data field is a Map', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'messages': [tMsgJson],
            'pagination': {'total': 1},
          },
        }),
      );

      final (msgs, total) = await ds.getMessages(conversationId: 'c1');

      expect(msgs, hasLength(1));
      expect(msgs.first.messageId, 'm1');
      expect(total, 1);
    });

    test('parses messages when data field is a List', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': [tMsgJson],
          'pagination': {'total': 1},
        }),
      );

      final (msgs, total) = await ds.getMessages(conversationId: 'c1');

      expect(msgs, hasLength(1));
      expect(total, 1);
    });

    test('returns empty list and zero total when data field is null', () async {
      when(
        () => mockDio.get(any()),
      ).thenAnswer((_) async => _resp({'data': null}));

      final (msgs, total) = await ds.getMessages(conversationId: 'c1');

      expect(msgs, isEmpty);
      expect(total, 0);
    });

    test('uses pagination.total from map when present', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'messages': [tMsgJson],
            'pagination': {'total': 99},
          },
        }),
      );

      final (_, total) = await ds.getMessages(conversationId: 'c1');

      expect(total, 99);
    });

    test('falls back to message count when pagination absent', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'messages': [tMsgJson],
          },
        }),
      );

      final (_, total) = await ds.getMessages(conversationId: 'c1');

      expect(total, 1);
    });

    test('uses top-level pagination when data is a List', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': [tMsgJson],
          'pagination': {'total': 10},
        }),
      );

      final (_, total) = await ds.getMessages(conversationId: 'c1');

      expect(total, 10);
    });

    test('throws when response data is not a map', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _resp('bad'));

      expect(() => ds.getMessages(conversationId: 'c1'), throwsException);
    });
  });

  // ─── sendMessage ─────────────────────────────────────────────────────────────

  group('sendMessage', () {
    test('returns parsed MessageModel on success', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _resp({'data': tMsgJson}));

      final req = SentMessageRequestModel(body: 'Hi');
      final result = await ds.sendMessage(
        conversationId: 'c1',
        requestContent: req,
      );

      expect(result.messageId, 'm1');
      expect(result.body, 'Hello');
    });

    test('calls the correct endpoint', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _resp({'data': tMsgJson}));

      await ds.sendMessage(
        conversationId: 'c1',
        requestContent: SentMessageRequestModel(body: 'Hi'),
      );

      verify(
        () => mockDio.post(
          ApiEndPoints.sendMessage('c1'),
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  // ─── newConversation ─────────────────────────────────────────────────────────

  group('newConversation', () {
    test(
      'returns conversation directly when response includes conversation key',
      () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => _resp({
            'data': {'conversation': tConvJson},
          }),
        );

        final result = await ds.newConversation(participantId: 'u2');

        expect(result.conversationId, 'c1');
        expect(result.participantId, 'u2');
      },
    );

    test(
      'falls back to getConversations when response has no conversation key',
      () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => _resp({'data': {}}));
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'items': [tConvJson],
            },
          }),
        );

        final result = await ds.newConversation(participantId: 'u2');

        expect(result.participantId, 'u2');
      },
    );

    test('throws when fallback finds no matching participant', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _resp({'data': {}}));
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'items': []},
        }),
      );

      expect(
        () => ds.newConversation(participantId: 'ghost-user'),
        throwsException,
      );
    });

    test('includes body in request when provided', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _resp({
          'data': {'conversation': tConvJson},
        }),
      );

      await ds.newConversation(participantId: 'u2', body: 'Hello!');

      final captured = verify(
        () => mockDio.post(any(), data: captureAny(named: 'data')),
      ).captured;
      expect((captured.single as Map)['body'], 'Hello!');
    });

    test('includes track resource when trackId provided', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _resp({
          'data': {'conversation': tConvJson},
        }),
      );

      await ds.newConversation(participantId: 'u2', trackId: 't1');

      final captured = verify(
        () => mockDio.post(any(), data: captureAny(named: 'data')),
      ).captured;
      expect((captured.single as Map)['resource'], {
        'type': 'track',
        'id': 't1',
      });
    });

    test('includes playlist resource when playlistId provided', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _resp({
          'data': {'conversation': tConvJson},
        }),
      );

      await ds.newConversation(participantId: 'u2', playlistId: 'pl1');

      final captured = verify(
        () => mockDio.post(any(), data: captureAny(named: 'data')),
      ).captured;
      expect((captured.single as Map)['resource'], {
        'type': 'playlist',
        'id': 'pl1',
      });
    });
  });

  // ─── ensureConversation ───────────────────────────────────────────────────────

  group('ensureConversation', () {
    test('returns conversation on success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _resp({
          'data': {'conversation': tConvJson},
        }),
      );

      final result = await ds.ensureConversation(participantId: 'u2');

      expect(result.conversationId, 'c1');
      verify(
        () => mockDio.post(
          ApiEndPoints.ensureConversation,
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  // ─── getUnreadCount ───────────────────────────────────────────────────────────

  group('getUnreadCount', () {
    test('returns unread count on success', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'unread_count': 5},
        }),
      );

      expect(await ds.getUnreadCount(), 5);
    });

    test('returns 0 when count is zero', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'unread_count': 0},
        }),
      );

      expect(await ds.getUnreadCount(), 0);
    });
  });

  // ─── blockUser ────────────────────────────────────────────────────────────────

  group('blockUser', () {
    test('completes without error', () async {
      when(() => mockDio.post(any())).thenAnswer((_) async => _resp(null));

      await expectLater(ds.blockUser(userId: 'u2'), completes);
      verify(() => mockDio.post(ApiEndPoints.blockUser('u2'))).called(1);
    });
  });

  // ─── unBlockUser ─────────────────────────────────────────────────────────────

  group('unBlockUser', () {
    test('completes without error', () async {
      when(() => mockDio.delete(any())).thenAnswer((_) async => _resp(null));

      await expectLater(ds.unBlockUser(userId: 'u2'), completes);
      verify(() => mockDio.delete(ApiEndPoints.unBlockUser('u2'))).called(1);
    });
  });

  // ─── markMessagesAsRead ───────────────────────────────────────────────────────

  group('markMessagesAsRead', () {
    test('completes on success', () async {
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _resp(null));

      await expectLater(
        ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1'),
        completes,
      );
    });

    test('swallows 409 DioException silently', () async {
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenThrow(_dioEx(409));

      await expectLater(
        ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1'),
        completes,
      );
    });

    test('rethrows non-409 DioException', () async {
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenThrow(_dioEx(500));

      expect(
        () => ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1'),
        throwsA(isA<DioException>()),
      );
    });

    test('sends correct endpoint and payload', () async {
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _resp(null));

      await ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1');

      verify(
        () => mockDio.patch(
          ApiEndPoints.markMessagesAsRead('c1', 'm1'),
          data: {'is_read': true},
        ),
      ).called(1);
    });
  });

  // ─── getFollowings ────────────────────────────────────────────────────────────

  group('getFollowings', () {
    test('returns list of potential conversations', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'items': [tUserJson],
          },
        }),
      );

      final result = await ds.getFollowings('me');

      expect(result, hasLength(1));
      expect(result.first.participantId, 'u2');
      expect(result.first.participantName, 'Alice');
    });

    test('returns empty list when items is empty', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'items': []},
        }),
      );

      expect(await ds.getFollowings('me'), isEmpty);
    });

    test('propagates DioException', () async {
      when(() => mockDio.get(any())).thenThrow(_dioEx(401));

      expect(() => ds.getFollowings('me'), throwsA(isA<DioException>()));
    });
  });

  // ─── getSearchedUsers ─────────────────────────────────────────────────────────

  group('getSearchedUsers', () {
    test('returns matching users', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'users': [tUserJson],
          },
        }),
      );

      final result = await ds.getSearchedUsers('ali');

      expect(result, hasLength(1));
      expect(result.first.participantId, 'u2');
    });

    test('returns empty list when no users match', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'users': []},
        }),
      );

      expect(await ds.getSearchedUsers('zzz'), isEmpty);
    });

    test('propagates DioException', () async {
      when(() => mockDio.get(any())).thenThrow(_dioEx(500));

      expect(() => ds.getSearchedUsers('ali'), throwsA(isA<DioException>()));
    });
  });

  // ─── isBlocked ────────────────────────────────────────────────────────────────

  group('isBlocked', () {
    test('returns true when is_blocking is true', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'is_blocking': true, 'is_blocked_by': false},
        }),
      );

      expect(await ds.isBlocked('u2'), true);
    });

    test('returns false when is_blocking is false', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'is_blocking': false, 'is_blocked_by': false},
        }),
      );

      expect(await ds.isBlocked('u2'), false);
    });

    test('throws when response data is not a map', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _resp('bad'));

      expect(() => ds.isBlocked('u2'), throwsException);
    });
  });

  // ─── isBlockedBy ─────────────────────────────────────────────────────────────

  group('isBlockedBy', () {
    test('returns true when is_blocked_by is true', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'is_blocking': false, 'is_blocked_by': true},
        }),
      );

      expect(await ds.isBlockedBy('u2'), true);
    });

    test('returns false when is_blocked_by is false', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'is_blocking': false, 'is_blocked_by': false},
        }),
      );

      expect(await ds.isBlockedBy('u2'), false);
    });

    test('throws when response data is not a map', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _resp('bad'));

      expect(() => ds.isBlockedBy('u2'), throwsException);
    });
  });

  // ─── getEmbeds ────────────────────────────────────────────────────────────────

  group('getEmbeds', () {
    group('track', () {
      test('returns SharedEmbedModels from liked tracks', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'items': [
                {
                  'track_id': 't1',
                  'title': 'Track One',
                  'cover_image': 'http://img',
                },
              ],
            },
          }),
        );

        final result = await ds.getEmbeds('me', 'track');

        expect(result, hasLength(1));
        expect(result.first.embedId, 't1');
        expect(result.first.embedType, 'track');
        expect(result.first.embedName, 'Track One');
      });

      test('falls back to id field when track_id absent', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'items': [
                {'id': 't2', 'title': 'Track Two', 'cover_image': null},
              ],
            },
          }),
        );

        final result = await ds.getEmbeds('me', 'track');

        expect(result.first.embedId, 't2');
      });
    });

    group('playlist', () {
      test(
        'merges liked and created playlists and deduplicates by id',
        () async {
          final likedItems = [
            {'id': 'p1', 'name': 'Liked One', 'cover_image': null},
            {'id': 'p2', 'name': 'Shared', 'cover_image': null},
          ];
          final createdItems = [
            {'id': 'p2', 'name': 'Shared', 'cover_image': null},
            {'id': 'p3', 'name': 'Created One', 'cover_image': null},
          ];

          when(
            () => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ),
          ).thenAnswer((inv) async {
            final url = inv.positionalArguments.first as String;
            if (url.contains('liked-playlists')) {
              return _resp({
                'data': {'items': likedItems},
              });
            }
            return _resp({
              'data': {'items': createdItems},
            });
          });

          final result = await ds.getEmbeds('me', 'playlist');

          expect(result, hasLength(3));
          expect(result.map((e) => e.embedId), containsAll(['p1', 'p2', 'p3']));
        },
      );

      test('skips items missing id or name', () async {
        final items = [
          {'id': 'p1', 'name': 'Valid', 'cover_image': null},
          {'name': 'No ID', 'cover_image': null},
          {'id': 'p3', 'cover_image': null},
        ];

        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _resp({
            'data': {'items': items},
          }),
        );

        final result = await ds.getEmbeds('me', 'playlist');

        // Only 'p1' has both id and non-empty name; 'p3' has empty name
        expect(result.map((e) => e.embedId), contains('p1'));
        expect(result.any((e) => e.embedId == 'p3'), false);
      });

      test('returns empty list when both sources are empty', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _resp({
            'data': {'items': []},
          }),
        );

        expect(await ds.getEmbeds('me', 'playlist'), isEmpty);
      });
    });

    group('album', () {
      test('returns SharedEmbedModels from liked albums', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'items': [
                {'playlist_id': 'a1', 'name': 'Album One', 'cover_image': null},
              ],
            },
          }),
        );

        final result = await ds.getEmbeds('me', 'album');

        expect(result, hasLength(1));
        expect(result.first.embedId, 'a1');
        expect(result.first.embedType, 'album');
      });
    });

    test('returns empty list for unknown embedType', () async {
      final result = await ds.getEmbeds('me', 'video');
      expect(result, isEmpty);
    });
  });

  // ─── getTrackDetails ─────────────────────────────────────────────────────────

  group('getTrackDetails', () {
    test('parses track with artist_name field', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'id': 't1',
            'title': 'My Track',
            'artist_name': 'DJ One',
            'cover_image': 'http://img',
          },
        }),
      );

      final result = await ds.getTrackDetails('t1');

      expect(result.embedId, 't1');
      expect(result.embedName, 'My Track');
      expect(result.artistName, 'DJ One');
      expect(result.thumbnailUrl, 'http://img');
    });

    test('falls back to artist field when artist_name is absent', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'id': 't1',
            'title': 'My Track',
            'artist': 'DJ Two',
            'artwork_url': 'http://art',
          },
        }),
      );

      final result = await ds.getTrackDetails('t1');

      expect(result.artistName, 'DJ Two');
      expect(result.thumbnailUrl, 'http://art');
    });

    test(
      'falls back to artists field when both artist_name and artist absent',
      () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'id': 't1',
              'title': 'Collab',
              'artists': 'Artist A & Artist B',
              'cover_image': null,
            },
          }),
        );

        final result = await ds.getTrackDetails('t1');

        expect(result.artistName, 'Artist A & Artist B');
      },
    );

    test('calls correct endpoint', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {'id': 't1', 'title': 'Track', 'cover_image': null},
        }),
      );

      await ds.getTrackDetails('t1');

      verify(() => mockDio.get(ApiEndPoints.getTrackDetails('t1'))).called(1);
    });
  });

  // ─── getPlaylistDetails ───────────────────────────────────────────────────────

  group('getPlaylistDetails', () {
    test('returns playlist embed using playlist_id from response', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'playlist_id': 'pl1',
            'name': 'My Playlist',
            'owner_name': 'Alice',
            'cover_image': 'http://img',
          },
        }),
      );

      final result = await ds.getPlaylistDetails('pl1', 'playlist');

      expect(result.embedId, 'pl1');
      expect(result.embedName, 'My Playlist');
      expect(result.artistName, 'Alice');
      expect(result.embedType, 'playlist');
    });

    test(
      'falls back to playlistId param when playlist_id absent in response',
      () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => _resp({
            'data': {
              'name': 'My Album',
              'owner_name': 'Bob',
              'cover_image': null,
            },
          }),
        );

        final result = await ds.getPlaylistDetails('a1', 'album');

        expect(result.embedId, 'a1');
        expect(result.embedType, 'album');
      },
    );

    test('calls correct endpoint', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => _resp({
          'data': {
            'playlist_id': 'pl1',
            'name': 'P',
            'owner_name': 'X',
            'cover_image': null,
          },
        }),
      );

      await ds.getPlaylistDetails('pl1', 'playlist');

      verify(
        () => mockDio.get(ApiEndPoints.getPlaylistDetails('pl1')),
      ).called(1);
    });
  });
}
