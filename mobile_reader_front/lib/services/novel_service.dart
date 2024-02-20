// novel_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/services/api.dart';

class NovelService {
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  static Future<Map<String, dynamic>> copytohistory() async {
    final response = await Api().post(
      '$baseUrl/user/copyNovelToHistory',
      {},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add novel');
    }
  }

  static Future<Map<String, dynamic>> addNovel(
      Map<String, dynamic> novelDetails) async {
    final response = await Api().post(
      '$baseUrl/user/addNovel',
      {'novelDetails': novelDetails},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add novel');
    }
  }

  static Future<List<dynamic>> searchNovels(String searchValue) async {
    final response =
        await Api().get('$baseUrl/api/search?keyword=$searchValue');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load chapter content');
    }
  }

  static Future<Map<String, dynamic>> fetchChapters(String novelUrl) async {
    final response =
        await Api().get('$baseUrl/api/chapters?novelUrl=$novelUrl');

    if (response.statusCode == 200) {
      Log.logger.i("response body: ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  static Future<String> fetchChapterContent(String chapterUrl) async {
    final response =
        await Api().get('$baseUrl/api/chapter-content?chapterUrl=$chapterUrl');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'];
    } else {
      throw Exception('Failed to load chapter content');
    }
  }

  static Future<Map<String, dynamic>> updateFavoriteStatus(
      String novelTitle, bool isFavorite) async {
    final response = await Api().patch(
      '$baseUrl/user/updateFavoriteStatus',
      {'novelTitle': novelTitle, 'isFavorite': isFavorite},
    );

    if (response.statusCode == 200) {
      Log.logger.i("response body: ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update favorite status');
    }
  }

  static Future<Map<String, dynamic>> updateLastRead(
      String novelTitle, int lastReadChapter) async {
    final response = await Api().patch(
      '$baseUrl/user/updateLastRead',
      {'novelTitle': novelTitle, 'lastReadChapter': lastReadChapter},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update last read chapter');
    }
  }

  static Future<Map<String, dynamic>> addChapterRead(
      String novelTitle, int chapter) async {
    final response = await Api().post(
      '$baseUrl/user/addChapterRead',
      {'novelTitle': novelTitle, 'chapter': chapter},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add chapter read');
    }
  }

  static Future<Map<String, dynamic>> removeChapterRead(
      String novelTitle, int chapter) async {
    final response = await Api().delete(
      '$baseUrl/user/removeChapterRead',
      {'novelTitle': novelTitle, 'chapter': chapter},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to remove chapter read');
    }
  }

  static Future<Map<String, dynamic>> addOrUpdateHistoryByTitle(
      String novelTitle) async {
    final response = await Api().post(
      '$baseUrl/user/addOrUpdateHistory',
      {'novelTitle': novelTitle},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add or update novel in history by title');
    }
  }
}
