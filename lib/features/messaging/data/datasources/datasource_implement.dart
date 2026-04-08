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
  Future<List<MessageModel>> getMessages({
    required String conversationId,
  }) async {
    final response = await dio.get(
      ApiEndPoints.getConversation(conversationId),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final List data = body['data']['messages'];

    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
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
  Future<int> getUnreadCount() async {
    final response = await dio.get(ApiEndPoints.getUnreadCount);
    return response.data['data']['unread_count'] as int;
  }

  @override
  Future<void> blockUser({required String userId}) async {
    await dio.post(ApiEndPoints.blockUser(userId));
  }

  @override
  Future<void> unBlockUser({required String userId}) async {
    await dio.delete(ApiEndPoints.unBlockUser(userId));
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    await dio.patch(
      ApiEndPoints.markMessagesAsRead(conversationId, messageId),
      data: {'is_read': true},
    );
  }

  @override
  Future<List<PotentialConversationModel>> getFollowings(String myId) async {
    try {
      final url = ApiEndPoints.getFollowings();
      print('FOLLOWINGS URL: $url');

      final response = await dio.get(url);

      final body = response.data;
      final List data = body['data']['items'];

      return data
          .map(
            (e) =>
                PotentialConversationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      print('FOLLOWINGS ERROR STATUS: ${e.response?.statusCode}');
      print('FOLLOWINGS REQUEST URI: ${e.requestOptions.uri}');
      print('FOLLOWINGS ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<List<PotentialConversationModel>> getSearchedUsers(
    String query,
  ) async {
    try {
      final url = ApiEndPoints.getSearchedUsers(query);
      print('SEARCH USERS URL: $url');

      final response = await dio.get(url);

      final body = response.data;
      final List data = body['data']['items'];

      return data
          .map(
            (e) =>
                PotentialConversationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      print('SEARCH USERS ERROR STATUS: ${e.response?.statusCode}');
      print('SEARCH USERS REQUEST URI: ${e.requestOptions.uri}');
      print('SEARCH USERS ERROR DATA: ${e.response?.data}');
      rethrow;
    }
  }

  @override
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
  Future<List<SharedEmbedModel>> getEmbeds(
    String userId,
    String embedType,
  ) async {
    if (embedType == 'track') {
      final response = await dio.get(ApiEndPoints.getMyLikedTracks());
      final List data = response.data['data'];
      return data
          .map(
            (e) => SharedEmbedModel(
              embedId: e['id'],
              embedType: 'track',
              embedName: e['title'],
              artistName: null,
              thumbnailUrl: e['cover_image'],
            ),
          )
          .toList();
    } else if (embedType == 'playlist') {
      final response = await dio.get(ApiEndPoints.getMyLikedPlaylists());
      final List data = response.data['data']['items'];
      return data
          .map(
            (e) => SharedEmbedModel(
              embedId: e['playlist_id'],
              embedType: 'playlist',
              embedName: e['name'],
              artistName: null,
              thumbnailUrl: e['cover_image'],
            ),
          )
          .toList();
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
  Future<SharedEmbedModel> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndPoints.getTrackDetails(trackId));
    final data = response.data['data'];
    return SharedEmbedModel(
      embedId: data['id'],
      embedType: 'track',
      embedName: data['title'],
      artistName: data['artists'],
      thumbnailUrl: null,
    );
  }

  @override
  Future<SharedEmbedModel> getPlaylistDetails(
    String playlistId,
    String embedType,
  ) async {
    //can give me playlists and albums
    final response = await dio.get(ApiEndPoints.getPlaylistDetails(playlistId));
    final data = response.data['data'];
    return SharedEmbedModel(
      embedId: data['playlist_id'],
      embedType: embedType,
      embedName: data['name'],
      artistName: null,
      thumbnailUrl: null,
    );
  }
}
