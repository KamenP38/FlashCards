import 'package:flutter/material.dart';
import 'package:mp3/models/deck_model.dart';
import 'package:mp3/models/flashcard_model.dart';
import 'package:provider/provider.dart';

class FlashcardEditPage extends StatefulWidget {
  final int? flashcardIndex;
  final bool isNewFlashcard;
  final int deckId;

  const FlashcardEditPage(
    this.flashcardIndex, 
    this.isNewFlashcard,
    this.deckId,
    {super.key});

  @override
  State<FlashcardEditPage> createState() => _FlashcardEditPageState();
}

class _FlashcardEditPageState extends State<FlashcardEditPage>{
  late FlashcardModel _editedFlashcard;
  late FlashcardCollection _collection;

  @override
  void initState() {
    super.initState();

    // Grab the collection and the Flashcards we are editing from the context
    _collection = Provider.of<FlashcardCollection>(context, listen: false);

    if (widget.isNewFlashcard){
      _editedFlashcard = FlashcardModel(deckId: widget.deckId, question: '', answer: '');
    } else{
      _editedFlashcard = FlashcardModel.from(_collection[widget.flashcardIndex!], widget.deckId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckCollection = Provider.of<DeckCollection>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Flashcard')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextFormField(
                    initialValue: _editedFlashcard.question,
                    decoration: const InputDecoration(hintText: 'Question'),
                    onChanged: (value) => _editedFlashcard.question = value,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextFormField(
                    initialValue: _editedFlashcard.answer,
                    decoration: const InputDecoration(hintText: 'Answer'),
                    onChanged: (value) => _editedFlashcard.answer = value,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (widget.isNewFlashcard){
                        _collection.add(_editedFlashcard);
                        deckCollection[_editedFlashcard.deckId - 1].flashcardCount++;
                      } else {
                        // just update the Flashcard in the collection -- it will
                        // take care of notifying its listeners
                        _collection.update(widget.flashcardIndex!, _editedFlashcard);
                        }
                      Navigator.of(context).pop();
                    },
                  ),
                  if(!widget.isNewFlashcard)
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        _collection.remove(widget.flashcardIndex!);
                        Navigator.of(context).pop();
                      },
                    )
                  ] 
                ),
              ],
            ),
          ),
        ));
  }
}