import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class DeckModel {
  int? id;
  String title;
  int flashcardCount;

  DeckModel({
    this.id,
    required this.title,
    required this.flashcardCount,
  });

  DeckModel.from(DeckModel other)
      : id = other.id,
        title = other.title,
        flashcardCount = other.flashcardCount;

  @override
  bool operator ==(Object other) {
    return other is DeckModel && other.id == id && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  // save deck to db
  Future<void> dbSave() async {
    // update id with the newly inserted record's id
    id = await DBHelper().insert('deck', {
      'title': title,
      'flashcardCount': flashcardCount
    });
  }
}

class DeckCollection with ChangeNotifier {
  final List<DeckModel> _decks;

  DeckCollection({List<DeckModel>? initialDecks}) : _decks = initialDecks ?? [];

  int get length => _decks.length;

  DeckModel operator [](int index) => _decks[index];

  Future<void> update(int index, DeckModel deck) async {
    _decks[index] = deck;
    notifyListeners();

    await DBHelper().update('deck', {'title': deck.title, 'flashcardCount': deck.flashcardCount},
        where: 'id = ?', whereArgs: [deck.id]);
  }

  Future<void> add(DeckModel newDeck) async {
    _decks.add(newDeck);
    notifyListeners();
    int deckId = await DBHelper().insert('deck', {'title': newDeck.title, 'flashcardCount': 0});

    newDeck.id = deckId;
  }

  Future<void> remove(int index) async {
    final deckId = _decks[index].id!;
    _decks.removeAt(index);
    notifyListeners();

    await DBHelper().delete('deck', where: 'id = ?', whereArgs: [deckId]);
    await DBHelper()
        .delete('flashcard', where: 'deckId = ?', whereArgs: [deckId]);
  }

  Future<void> reloadDecks() async {
    // Load data from the database and update the deck collection
    final dbHelper = DBHelper();
    List<Map<String, dynamic>> data = await dbHelper.query('deck');

    _decks.clear();
    _decks.addAll(data
        .map((e) => DeckModel(
              id: e['id'] as int,
              title: e['title'] as String,
              flashcardCount: e['flashcardCount'] as int,
            ))
        .toList());

    notifyListeners();
  }
}
