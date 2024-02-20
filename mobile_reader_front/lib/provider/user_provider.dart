import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:mobile_reader_front/models/user.dart';

final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

class UserProvider extends ChangeNotifier {
  User? _user;

  // Expose user data through getters
  String get username => _user?.username ?? '';
  String get uniqueIdentifier => _user?.uniqueIdentifier ?? '';
  DateTime get dateJoined => _user?.dateJoined ?? DateTime.now();
  String get profileImage => _user?.profileImage ?? '';
  String get theme => _user?.theme ?? '';
  List<Map<String, dynamic>> get friends => _user?.friends ?? [];
  List<Novel> get novels => _user?.novels ?? [];
  List<Novel> get historyNovels => _user?.historyNovels ?? [];

  // Update profile image
  void updateProfileImage(String newImageUrl) {
    if (_user != null) {
      _user = User(
        username: _user!.username,
        uniqueIdentifier: _user!.uniqueIdentifier,
        dateJoined: _user!.dateJoined,
        profileImage: newImageUrl,
        theme: _user!.theme,
        friends: _user!.friends,
        novels: _user!.novels,
        historyNovels: _user!.historyNovels,
      );
      notifyListeners();
    }
  }

  // Update a novel's favorite status
  void toggleFavoriteStatus(String novelTitle) {
    if (_user != null && _user!.novels.isNotEmpty) {
      final novelIndex =
          _user!.novels.indexWhere((novel) => novel.novelTitle == novelTitle);
      if (novelIndex != -1) {
        final updatedNovel = _user!.novels[novelIndex].copyWith(
          isFavorite: !_user!.novels[novelIndex].isFavorite,
        );
        _user!.novels[novelIndex] = updatedNovel;
        Log.logger.i("Novel updated: ${updatedNovel.isFavorite}");

        notifyListeners();
      }
    }
  }

  // Set user data from a Map<String, dynamic>
  void setUserData(Map<String, dynamic> userDetails) {
    _user = User.fromJson(userDetails);
    Log.logger.i('Set user data called');
  }
}
