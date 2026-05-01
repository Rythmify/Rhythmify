import 'package:dio/dio.dart';
import 'package:rythmify/features/messaging/data/datasources/api_endpoints.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/data/models/shared_embed_model.dart';

/// Concrete implementation of [DatasourceInterface] using the Dio HTTP client.
///
/// This class handles all remote messaging operations by making asynchronous
/// requests to the specified [ApiEndPoints].
class DatasourceImplement implements DatasourceInterface {
  /// The Dio HTTP client used for making network requests.
  final Dio dio;
  DatasourceImplement({required this.dio});

  @override
  /// Fetches all conversations for the current user from `GET /messages/conversations`.
  ///
  /// Expects a JSON envelope `{ data: { items: [...] } }`.
  Future<List<ConversationModel>> getConversations() async {
    final response = await dio.get(ApiEndPoints.getConversations);
    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final List data = body['data']['items'];

    return data
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  /// Fetches a page of messages for [conversationId] at [offset].
  ///
  /// Handles two response shapes: `data` as a Map containing `messages` + `pagination`,
  /// or `data` as a raw List. Falls back to `rawMessages.length` when `total` is absent.
  /// Returns a tuple of the parsed [MessageModel] list and the total message count.
  Future<(List<MessageModel>, int)> getMessages({
    required String conversationId,
    int offset = 0,
  }) async {
    final response = await dio.get(
      ApiEndPoints.getMessages(conversationId, offset: offset),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final dynamic dataField = body['data'];
    final List rawMessages;
    final int total;

    if (dataField is Map) {
      rawMessages = (dataField['messages'] as List?) ?? [];
      final pagination =
          dataField['pagination'] as Map? ?? body['pagination'] as Map? ?? {};
      total = (pagination['total'] as int?) ?? rawMessages.length;
    } else if (dataField is List) {
      rawMessages = dataField;
      final pagination = body['pagination'] as Map? ?? {};
      total = (pagination['total'] as int?) ?? rawMessages.length;
    } else {
      rawMessages = [];
      total = 0;
    }

    final messages = rawMessages
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (messages, total);
  }

  @override
  /// Sends a message to [conversationId] via `POST /messages/conversations/{id}/messages`.
  ///
  /// Serialises [requestContent] to JSON and returns the created [MessageModel].
  Future<MessageModel> sendMessage({
    required String conversationId,
    required SentMessageRequestModel requestContent,
  }) async {
    final response = await dio.post(
      ApiEndPoints.sendMessage(conversationId),
      data: requestContent.toJson(),
    );
    return MessageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  /// Starts a new conversation with [participantId] via `POST /messages/new`.
  ///
  /// Optionally attaches a text [body] or a music resource ([trackId] or [playlistId]).
  /// If the response does not contain a `conversation` key, falls back to fetching
  /// the conversation list and finding the one matching [participantId].
  Future<ConversationModel> newConversation({
    required String participantId,
    String? body,
    String? trackId,
    String? playlistId,
  }) async {
    final data = <String, dynamic>{'recipient_id': participantId};
    if (body != null) data['body'] = body;
    if (trackId != null) data['resource'] = {'type': 'track', 'id': trackId};
    if (playlistId != null) {
      data['resource'] = {'type': 'playlist', 'id': playlistId};
    }

    final response = await dio.post(ApiEndPoints.newConversation, data: data);

    final responseData = response.data['data'];
    if (responseData.containsKey('conversation')) {
      return ConversationModel.fromJson(responseData['conversation']);
    } else {
      final conversations = await getConversations();
      return conversations.firstWhere(
        (c) => c.participantId == participantId,
        orElse: () => throw Exception('Conversation not found'),
      );
    }
  }

  @override
  /// Ensures a conversation with [participantId] exists via `POST /messages/conversations/ensure`.
  ///
  /// Creates the conversation if it doesn't exist; returns the existing one otherwise.
  /// Used when navigating to a chat screen without sending a message.
  Future<ConversationModel> ensureConversation({
    required String participantId,
  }) async {
    final response = await dio.post(
      ApiEndPoints.ensureConversation,
      data: {'recipient_id': participantId},
    );
    return ConversationModel.fromJson(
      response.data['data']['conversation'] as Map<String, dynamic>,
    );
  }

  @override
  /// Returns the total number of unread messages via `GET /messages/unread-count`.
  Future<int> getUnreadCount() async {
    final response = await dio.get(ApiEndPoints.getUnreadCount);
    return response.data['data']['unread_count'] as int;
  }

  @override
  /// Blocks [userId] via `POST /users/{userId}/block`.
  Future<void> blockUser({required String userId}) async {
    await dio.post(ApiEndPoints.blockUser(userId));
  }

  @override
  /// Unblocks [userId] via `DELETE /users/{userId}/block`.
  Future<void> unBlockUser({required String userId}) async {
    await dio.delete(ApiEndPoints.unBlockUser(userId));
  }

  @override
  /// Marks [messageId] as read via `PATCH /messages/conversations/{convId}/messages/{msgId}/read`.
  ///
  /// A 409 response means the message is already read and is silently swallowed.
  /// All other [DioException]s are rethrown.
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await dio.patch(
        ApiEndPoints.markMessagesAsRead(conversationId, messageId),
        data: {'is_read': true},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return;
      rethrow;
    }
  }

  @override
  /// Returns the list of users followed by the current user via `GET /users/me/following`.
  Future<List<PotentialConversationModel>> getFollowings(String myId) async {
    try {
      final url = ApiEndPoints.getFollowings();

      final response = await dio.get(url);

      final body = response.data;
      final List data = body['data']['items'];

      return data
          .map(
            (e) =>
                PotentialConversationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  /// Searches for users matching [query] via `GET /search?q={query}&type=users`.
  Future<List<PotentialConversationModel>> getSearchedUsers(
    String query,
  ) async {
    try {
      final url = ApiEndPoints.getSearchedUsers(query);

      final response = await dio.get(url);
      final body = response.data;
      final List raw = body['data']['users'];

      return raw
          .map(
            (e) =>
                PotentialConversationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  /// Returns `true` if the current user has blocked [participantId].
  ///
  /// Reads the `is_blocking` field from `GET /users/{id}/follow-status`.
  Future<bool> isBlocked(String participantId) async {
    final response = await dio.get(ApiEndPoints.isBlocked(participantId));

    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return data['is_blocking'] as bool;
  }

  @override
  /// Returns `true` if [participantId] has blocked the current user.
  ///
  /// Reads the `is_blocked_by` field from the same `GET /users/{id}/follow-status`
  /// endpoint used by [isBlocked].
  Future<bool> isBlockedBy(String participantId) async {
    final response = await dio.get(
      ApiEndPoints.isBlocked(participantId), //same endpoint as isBlocked
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return data['is_blocked_by'] as bool;
  }

  @override
  /// Returns the current user's liked embeds filtered by [embedType].
  ///
  /// - `track`: fetches liked tracks from `GET /me/liked-tracks`.
  /// - `playlist`: merges liked playlists and user-created playlists,
  ///   deduplicating by ID so the same playlist never appears twice.
  /// - `album`: fetches liked albums from `GET /me/liked-albums`.
  Future<List<SharedEmbedModel>> getEmbeds(
    String userId,
    String embedType,
  ) async {
    if (embedType == 'track') {
      final response = await dio.get(ApiEndPoints.getMyLikedTracks());
      final List data = response.data['data']['items'];
      // if (data.isNotEmpty)
      //   print('🎵 liked-track item keys: ${(data.first as Map).keys.toList()}');
      return data
          .map(
            (e) => SharedEmbedModel(
              embedId: e['track_id'] ?? e['id'],
              embedType: 'track',
              embedName: e['title'],
              artistName: null,
              thumbnailUrl: e['cover_image'],
            ),
          )
          .toList();
    } else if (embedType == 'playlist') {
      final response = await Future.wait([
        dio.get(ApiEndPoints.getMyLikedPlaylists()),
        dio.get(
          '/playlists',
          queryParameters: {'mine': true, 'filter': 'created', 'limit': 50},
        ),
      ]);
      final List likedData = response[0].data['data']['items'] as List? ?? [];
      final List createdData = response[1].data['data']['items'] as List? ?? [];

      final seen = <String>{};
      final merged = <SharedEmbedModel>[];
      for (final e in [...likedData, ...createdData]) {
        final id = (e['id'] ?? e['playlist_id']) as String?;
        final name = (e['name'] as String?) ?? (e['title'] as String?) ?? '';
        if (id != null && name.isNotEmpty && seen.add(id)) {
          merged.add(
            SharedEmbedModel(
              embedId: id,
              embedType: 'playlist',
              embedName: name,
              artistName: null,
              thumbnailUrl: e['cover_image'] as String?,
            ),
          );
        }
      }
      return merged;
    } else if (embedType == 'album') {
      final response = await dio.get(ApiEndPoints.getMyLikedAlbums());
      final List data = response.data['data']['items'];
      return data
          .map(
            (e) => SharedEmbedModel(
              embedId: e['playlist_id'],
              embedType: 'album',
              embedName: e['name'],
              artistName: null,
              thumbnailUrl: e['cover_image'],
            ),
          )
          .toList();
    }

    return [];
  }

  @override
  /// Fetches track metadata for [trackId] from `GET /tracks/{trackId}`.
  ///
  /// Tries `artist_name`, then `artist`, then `artists` for the artist field
  /// to handle inconsistencies across different track response shapes.
  Future<SharedEmbedModel> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndPoints.getTrackDetails(trackId));
    final data = response.data['data'];
    return SharedEmbedModel(
      embedId: data['id'],
      embedType: 'track',
      embedName: data['title'],
      artistName: data['artist_name'] ?? data['artist'] ?? data['artists'],
      thumbnailUrl: data['cover_image'] ?? data['artwork_url'],
    );
  }

  @override
  /// Fetches playlist or album metadata from `GET /playlists/{playlistId}`.
  ///
  /// [embedType] is passed through to [SharedEmbedModel] to distinguish
  /// between `playlist` and `album` at the domain level.
  /// Falls back to [playlistId] when `playlist_id` is absent from the response.
  Future<SharedEmbedModel> getPlaylistDetails(
    String playlistId,
    String embedType,
  ) async {
    //can give me playlists and albums
    final response = await dio.get(ApiEndPoints.getPlaylistDetails(playlistId));
    final data = response.data['data'];
    return SharedEmbedModel(
      embedId: data['playlist_id'] ?? playlistId,
      embedType: embedType,
      embedName: data['name'],
      artistName: data['owner_name'],
      thumbnailUrl: data['cover_image'],
    );
  }
}
