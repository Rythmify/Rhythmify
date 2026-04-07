import '../models/user_model.dart';

abstract class UserRemoteDatasource {
  /// Fetches the current authenticated user's profile from the backend.
  ///
  /// Calls `GET /users/me` to retrieve the full user profile including
  /// all profile fields (bio, location, stats, etc.).
  ///
  /// This method should be called after any login to sync the user's
  /// complete profile data with the app state.
  ///
  /// Returns a [UserModel] with all available profile information.
  /// Throws an [Exception] on failure.
  Future<UserModel> getUserProfile();
}
