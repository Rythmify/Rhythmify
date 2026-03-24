/// Data Model: UploadResponseModel
///
/// Represents the server response after uploading a track.
///
/// Responsibilities:
/// - Parse JSON response from POST /tracks
/// - Extract track ID and status
///
/// Notes:
/// - Handles different response shapes from backend
/// - Only includes minimal data required by Upload module
/// - Full Track model is handled by M9 module
class UploadResponseModel {
  final String id;
  final String status; // "processing" initially

  const UploadResponseModel({required this.id, required this.status});

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    // Server might wrap response in a 'track' key or return directly
    // We handle both cases
    final data = json['track'] as Map<String, dynamic>? ?? json;

    return UploadResponseModel(
      id: data['id'] as String? ?? '',
      status: data['status'] as String? ?? 'processing',
    );
  }
}

//comments

///  the server's 201 response from POST /tracks.
/// We only extract what M13 needs — the track id.
/// M9 owns the full Track concept, not us.
/// the id is what our module M13 needs as a success result
