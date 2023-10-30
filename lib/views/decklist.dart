import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:mp3/models/flashcard_model.dart';
import 'package:mp3/views/deck_edit_page.dart';
import 'package:mp3/views/flashcardlist.dart';
import 'package:provider/provider.dart';
import '../utils/db_helper.dart';
import '../models/deck_model.dart';

class DeckListPage extends StatelessWidget {
  const DeckListPage({super.key});

  Future<List<DeckModel>> _loadData() async {
    final data = await DBHelper().query('deck');
    return data
        .map((e) => DeckModel(
              id: e['id'] as int,
              title: e['title'] as String,
              flashcardCount: (e['flashcardCount'] as int?) ?? 0,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DeckCollection>(
      create: (context) => DeckCollection(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<List<DeckModel>>(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Scaffold(
                      body: Center(child: Text("Error: ${snapshot.error}")));
                }

                final collection =
                    Provider.of<DeckCollection>(context, listen: false);
                collection.reloadDecks();
                return const DeckList();
              } else {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
            }),
      ),
    );
  }
}

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  bool _isLoading = false;

  Future<void> _insertFromJson() async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DBHelper();
    final String jsonString =
        await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    for (var deck in jsonData) {
      int flashcardCount = 0;
      int deckId = await dbHelper
          .insert('deck', {'title': deck['title'], 'flashcardCount': 0});

      for (var flashcard in deck['flashcards']) {
        flashcardCount++;
        await dbHelper.insert('flashcard', {
          'deckId': deckId,
          'question': flashcard['question'],
          'answer': flashcard['answer'],
        });
      }

      // Here we are going to update the count of the deck --> e.g., dbHelper.updateDeck
      await DBHelper().update('deck', {'flashcardCount': flashcardCount},
          where: 'id = ?', whereArgs: [deckId]);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<DeckCollection>(context);
    double width = MediaQuery.of(context).size.width;
    double titleFontSize, detailFontSize;

    int crossAxisCount;

    if (width <= 670) {
      // Small screen breakpoint
      titleFontSize = 12.0; // Smaller font for small screens
      detailFontSize = 10.0;
      crossAxisCount = 1; // 1 item per row for small screens
    } else if (width <= 900) {
      // Small Medium screen breakpoint
      titleFontSize = 16.0; // Medium font for medium screens
      detailFontSize = 14.0;
      crossAxisCount = 2; // 3 items per row for medium screens
    } else if (width <= 1200) {
      // Medium screen breakpoint
      titleFontSize = 18.0; // Medium font for medium screens
      detailFontSize = 16.0;
      crossAxisCount = 3; // 3 items per row for medium screens
    } else if (width <= 1400) {
      // Large Medium screen breakpoint
      titleFontSize = 20.0; // Medium font for medium screens
      detailFontSize = 16.0;
      crossAxisCount = 4; // 3 items per row for medium screens
    } else {
      // Large screen
      titleFontSize = 24.0; // Large font for large screens
      detailFontSize = 20.0;
      crossAxisCount = 5; // 5 items per row for large screens
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Decks'), actions: <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download Decks',
                onPressed: () {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  // final deckCollection =
                  //     Provider.of<DeckCollection>(context, listen: false);

                  _insertFromJson().then((_) {
                    scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Downloaded new decks.')));

                    // Refresh the deck collection
                    collection.reloadDecks();
                  });
                })),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridViewDecks(collection: collection, crossAxisCount: crossAxisCount, titleFontSize: titleFontSize, detailFontSize: detailFontSize),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const DeckEditPage(null, true);
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GridViewDecks extends StatelessWidget {
  const GridViewDecks({
    super.key,
    required this.collection,
    required this.crossAxisCount,
    required this.titleFontSize,
    required this.detailFontSize,
  });

  final DeckCollection collection;
  final int crossAxisCount;
  final double titleFontSize;
  final double detailFontSize;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: collection.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          final deck = collection[index];

          return Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.orange[100],
              child: Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return FlashcardListPage(deck: deck);
                        })).then((value) => collection.reloadDecks());
                      },
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                deck.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Flashcards: ${deck.flashcardCount}',
                                style: TextStyle(
                                  fontSize: detailFontSize,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return DeckEditPage(index, false);
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}
