import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/flashcard.dart';

/// Stores the user's flashcard collection on this browser/device.
class FlashcardStorage {
  static const _storageKey = 'memoria.flashcards.v1';

  Future<List<Flashcard>?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return null;

    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
        .toList(growable: true);
  }

  Future<bool> save(List<Flashcard> flashcards) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      flashcards.map((card) => card.toJson()).toList(),
    );
    return preferences.setString(_storageKey, encoded);
  }
}
