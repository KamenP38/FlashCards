import 'package:flutter/material.dart';
import 'package:mp3/models/deck_model.dart';
import 'package:mp3/models/flashcard_model.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/flashcard_edit_page.dart';
import 'package:mp3/views/flashcard_quiz_page.dart';
//import 'package:mp3/views/flashcard_quiz_page.dart';
import 'package:provider/provider.dart';

class FlashcardListPage extends StatelessWidget {
  final DeckModel deck;

  const FlashcardListPage({super.key, required this.deck});

  Future<List<FlashcardModel>> _loadData() async {
    final data = await DBHelper()
        .query('flashcard', where: 'deckId = ?', whereArgs: [deck.id!]);

    return data
        .map((e) => FlashcardModel(
              id: e['id'] as int,
              question: e['question'] as String,
              answer: e['answer'] as String,
              deckId: e['deckId'] as int,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlashcardModel>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Scaffold(
                  body: Center(child: Text("Error: ${snapshot.error}")));
            }

            final collection =
                FlashcardCollection(deck.id!, initialFlashcards: snapshot.data);
            return ChangeNotifierProvider<FlashcardCollection>.value(
              value: collection,
              child: FlashcardList(deck: deck),
            );
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class FlashcardList extends StatefulWidget {
  final DeckModel deck;

  const FlashcardList({required this.deck, super.key});

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  bool isSortedAlphabetically = false;
  

  @override
  Widget build(BuildContext context) {
    final flashcardCollection = Provider.of<FlashcardCollection>(context);
    List<FlashcardModel> flashcards = flashcardCollection.flashcardList;
    List<int> orderIndices = List.generate(flashcards.length, (index) => index);
    
    double width = MediaQuery.of(context).size.width;
    double questionFontSize;
    int crossAxisCount;
    double scaleDownFactor = 0.9;

    if (width <= 670) {
      // Small screen breakpoint
      questionFontSize = 12.0 * scaleDownFactor; 
      crossAxisCount = 2;
    } else if (width <= 900) {
      // Small Medium screen breakpoint
      questionFontSize = 16.0 * scaleDownFactor;
      crossAxisCount = 3; 
    } else if (width <= 1200) {
      // Medium screen breakpoint
      questionFontSize = 18.0 * scaleDownFactor; 
      crossAxisCount = 4; 
    } else if (width <= 1400) {
      // Large Medium screen breakpoint
      questionFontSize = 20.0 * scaleDownFactor; 
      crossAxisCount = 5; 
    } else {
      // Large screen
      questionFontSize = 24.0 * scaleDownFactor; 
      crossAxisCount = 6; 
    }


    orderIndices.sort(
        (a, b) => flashcards[a].question.compareTo(flashcards[b].question));

    if (isSortedAlphabetically) {
      orderIndices.sort(
          (a, b) => flashcards[a].question.compareTo(flashcards[b].question));
    } else {
      orderIndices.sort();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards'), actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: isSortedAlphabetically == false
              ? IconButton(
                  icon: const Icon(Icons.sort_by_alpha),
                  tooltip: 'Sort Cards',
                  onPressed: () {
                    setState(() {
                      isSortedAlphabetically = !isSortedAlphabetically;
                    });
                  })
              : IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Original Order',
                  onPressed: () {
                    setState(() {
                      isSortedAlphabetically = !isSortedAlphabetically;
                    });
                  }),
        ),
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
                icon: const Icon(Icons.quiz),
                tooltip: 'Quiz Time',
                onPressed: () async {
                  {
                    flashcardCollection.flashcardList.isEmpty ? 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No flashcards to be quizzed on.'))) :
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ChangeNotifierProvider.value(
                          value: flashcardCollection,
                          child: FlashcardQuizPage(flashcardCollection.deckId));
                    }));
                  }
                })),
      ]),
      body: GridViewCards(flashcardCollection: flashcardCollection, crossAxisCount: crossAxisCount, flashcards: flashcards, orderIndices: orderIndices, questionFontSize: questionFontSize),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ChangeNotifierProvider<FlashcardCollection>.value(
              value: flashcardCollection,
              child: FlashcardEditPage(null, true, flashcardCollection.deckId),
            );
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GridViewCards extends StatelessWidget {
  const GridViewCards({
    super.key,
    required this.flashcardCollection,
    required this.crossAxisCount,
    required this.flashcards,
    required this.orderIndices,
    required this.questionFontSize,
  });

  final FlashcardCollection flashcardCollection;
  final int crossAxisCount;
  final List<FlashcardModel> flashcards;
  final List<int> orderIndices;
  final double questionFontSize;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: flashcardCollection.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      itemBuilder: (context, index) {
        final flashcard = flashcards[orderIndices[index]];

        return Container(
          margin: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.orange[200],
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      //
                      {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ChangeNotifierProvider<
                              FlashcardCollection>.value(
                            value: flashcardCollection,
                            child: FlashcardEditPage(
                                index, false, flashcard.deckId),
                          );
                        }));
                      }
                    },
                    child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    flashcard.question,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: questionFontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
