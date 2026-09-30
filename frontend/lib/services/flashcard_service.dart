import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/flashcard.dart';

class FlashcardService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Récupérer toutes les flashcards
  Future<List<Flashcard>> getFlashcards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/flashcards/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Flashcard.fromJson(json))
          .toList();
    }

    throw Exception('Erreur lors du chargement des flashcards');
  }

  // Ajouter une flashcard
  Future<Flashcard> createFlashcard(
    String question,
    String answer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flashcards/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'question': question,
        'answer': answer,
      }),
    );

    if (response.statusCode == 201) {
      return Flashcard.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception('Erreur lors de la création');
  }

  // Modifier une flashcard
  Future<Flashcard> updateFlashcard(
    int id,
    String question,
    String answer,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/flashcards/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'question': question,
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return Flashcard.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception('Erreur lors de la modification');
  }

  // Supprimer une flashcard
  Future<void> deleteFlashcard(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/flashcards/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}