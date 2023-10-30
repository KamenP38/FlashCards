import 'package:flutter/material.dart';
import 'package:mp3/models/flashcard_model.dart';
import 'package:provider/provider.dart';

class FlashcardQuizPage extends StatefulWidget {
  final int deckId;

  const FlashcardQuizPage(this.deckId, {super.key});

  @override
  State<FlashcardQuizPage> createState() => _FlashcardQuizPageState();
}

class _FlashcardQuizPageState extends State<FlashcardQuizPage> {
  late FlashcardCollection _collection;
  late List<FlashcardModel> randomizedCards;
  late List<bool> seenCards;
  late List<bool> peekedCards;
  late List<bool> hasPeeked;
  int currentIndex = 0;
  int peekedCount = 0;

  @override
  void initState() {
    super.initState();

    // Grab the collection and the Flashcards from the context
    _collection = Provider.of<FlashcardCollection>(context, listen: false);
    randomizedCards = _collection.flashcardList;
    randomizedCards.shuffle();
    seenCards = List.generate(_collection.length, (index) => false);
    seenCards[0] = true;
    peekedCards = List.generate(_collection.length, (index) => false);
    hasPeeked = List.generate(_collection.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double fontSize;

    if (width <= 670) {
      // Small screen breakpoint
      fontSize = 25.0; 
    } else if (width <= 900) {
      // Small Medium screen breakpoint
      fontSize = 30.0;
    } else if (width <= 1200) {
      // Medium screen breakpoint
      fontSize = 35.0; 
    } else if (width <= 1400) {
      // Large Medium screen breakpoint
      fontSize = 40.0; 
    } else {
      // Large screen
      fontSize = 45.0; 
    }

    return Scaffold(
      appBar: AppBar(title: const Text("QUIZ")),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: peekedCards[currentIndex] == false
                          ? QuizCardQuestion(randomizedCards: randomizedCards, currentIndex: currentIndex, fontSize: fontSize)
                          : QuizCardAnswer(randomizedCards: randomizedCards, currentIndex: currentIndex, fontSize: fontSize),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  peekedCards[currentIndex] = false;
                                  currentIndex = (currentIndex -
                                          1 +
                                          randomizedCards.length) %
                                      randomizedCards.length;
                                  if (!seenCards[currentIndex]) {
                                    seenCards[currentIndex] = true;
                                  }
                                });
                              },
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            IconButton(
                              icon: const Icon(Icons.rotate_left),
                              onPressed: () {
                                // Logic for showing answer or moving to next card
                                setState(() {
                                  if (!peekedCards[currentIndex] &&
                                      !hasPeeked[currentIndex]) {
                                    hasPeeked[currentIndex] = true;
                                    peekedCount++;
                                  }
                                  peekedCards[currentIndex] =
                                      !peekedCards[currentIndex];
                                });
                              },
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                setState(() {
                                  peekedCards[currentIndex] = false;
                                  currentIndex = (currentIndex + 1) %
                                      randomizedCards.length;
                                  if (!seenCards[currentIndex]) {
                                    seenCards[currentIndex] = true;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        SeenPeekedInfo(seenCards: seenCards, randomizedCards: randomizedCards, peekedCount: peekedCount)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class SeenPeekedInfo extends StatelessWidget {
  const SeenPeekedInfo({
    super.key,
    required this.seenCards,
    required this.randomizedCards,
    required this.peekedCount,
  });

  final List<bool> seenCards;
  final List<FlashcardModel> randomizedCards;
  final int peekedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                  "Seen ${seenCards.where((card) => card).length} of ${randomizedCards.length} cards"),
              const SizedBox(height: 4),
              Text(
                  "Peeked at $peekedCount of ${seenCards.where((card) => card).length} answers")
            ],
          ),
        ],
      ),
    );
  }
}

class QuizCardAnswer extends StatelessWidget {
  const QuizCardAnswer({
    super.key,
    required this.randomizedCards,
    required this.currentIndex,
    required this.fontSize,
  });

  final List<FlashcardModel> randomizedCards;
  final int currentIndex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(25.0),
        child: Card(
          color: const Color.fromARGB(255, 196, 231, 155),
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              children: [
                InkWell(
                  child: Center(
                    child: Text(
                      randomizedCards[currentIndex]
                          .answer,
                          textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize + 5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class QuizCardQuestion extends StatelessWidget {
  const QuizCardQuestion({
    super.key,
    required this.randomizedCards,
    required this.currentIndex,
    required this.fontSize,
  });

  final List<FlashcardModel> randomizedCards;
  final int currentIndex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(25.0),
        child: Card(
          color: const Color.fromARGB(255, 226, 157, 53),
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              children: [
                InkWell(
                  child: Center(
                    child: Text(
                      randomizedCards[currentIndex]
                          .question,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: fontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
