import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class FlashcardModel {
  int? id;
  final int deckId;
  String question;
  String answer;

  FlashcardModel({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  FlashcardModel.from(FlashcardModel other, this.deckId)
      : id = other.id,
        question = other.question,
        answer = other.answer;

  @override
  bool operator ==(Object other) {
    return other is FlashcardModel &&
        other.id == id &&
        other.question == question;
  }

  @override
  int get hashCode => question.hashCode;

  // save deck to db
  Future<void> dbSave() async {
    // update id with the newly inserted recrod's id
    id = await DBHelper().insert('flashcard',
        {'question': question, 'answer': answer, 'deckId': deckId});
  }
}

class FlashcardCollection with ChangeNotifier {
  final int deckId;
  final List<FlashcardModel> _flashcards;

  FlashcardCollection(this.deckId, {List<FlashcardModel>? initialFlashcards})
      : _flashcards = initialFlashcards ?? [];

  int get length => _flashcards.length;

  List<FlashcardModel> get flashcardList => _flashcards;

  FlashcardModel operator [](int index) => _flashcards[index];


  Future<void> update(int index, FlashcardModel flashcard) async {
    _flashcards[index] = flashcard;
    notifyListeners();

    await DBHelper().update('flashcard',
        {'question': flashcard.question, 'answer': flashcard.answer},
        where: 'id = ?', whereArgs: [flashcard.id]);
  }

  Future<void> add(FlashcardModel newFlashcard) async {
    _flashcards.add(newFlashcard);
    notifyListeners();

    // Insert the deck into the database and get the deckId
    int newId = await DBHelper().insert('flashcard', {
      'deckId': newFlashcard.deckId,
      'question': newFlashcard.question,
      'answer': newFlashcard.answer
    });

    List<Map<String, dynamic>> decks = await DBHelper()
        .query('deck', where: 'id = ?', whereArgs: [newFlashcard.deckId]);

    if (decks.isNotEmpty) {
      Map<String, dynamic> currentDeck = decks.first;
      int currentFlashcardCount = currentDeck['flashcardCount'] as int;

      // Update the flashcardCount in the database
      await DBHelper().update(
          'deck', {'flashcardCount': currentFlashcardCount + 1},
          where: 'id = ?', whereArgs: [newFlashcard.deckId]);
    }

    newFlashcard.id = newId;
  }

  Future<void> remove(int index) async {
    int idToRemove = _flashcards[index].id!;
    int deckIdRm = _flashcards[index].deckId;
    _flashcards.removeAt(index);
    notifyListeners();

    List<Map<String, dynamic>> decks = await DBHelper()
        .query('deck', where: 'id = ?', whereArgs: [deckIdRm]);

    if (decks.isNotEmpty) {
      Map<String, dynamic> currentDeck = decks.first;
      int currentFlashcardCount = currentDeck['flashcardCount'] as int;

      // Update the flashcardCount in the database
      await DBHelper().update(
          'deck', {'flashcardCount': currentFlashcardCount - 1},
          where: 'id = ?', whereArgs: [deckIdRm]);
    }

    await DBHelper()
        .delete('flashcard', where: 'id = ?', whereArgs: [idToRemove]);

    
  }
}
