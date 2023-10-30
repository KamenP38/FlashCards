import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deck_model.dart';


class DeckEditPage extends StatefulWidget {
  final int? deckIndex;
  final bool isNewDeck;

  const DeckEditPage(
    this.deckIndex, 
    this.isNewDeck,
    {super.key});

  @override
  State<DeckEditPage> createState() => _DeckEditPageState();
}

class _DeckEditPageState extends State<DeckEditPage> {
  late DeckModel _editedDeck;
  late DeckCollection _collection;

  @override
  void initState() {
    super.initState();

    // Grab the collection and the Deck we are editing from the context
    _collection = Provider.of<DeckCollection>(context, listen: false);

    if (widget.isNewDeck){
      _editedDeck = DeckModel(title: '', flashcardCount: 0);
    } else{
      _editedDeck = DeckModel.from(_collection[widget.deckIndex!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Deck')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextFormField(
                    initialValue: _editedDeck.title,
                    decoration: const InputDecoration(hintText: 'Title'),
                    onChanged: (value) => _editedDeck.title = value,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (widget.isNewDeck){
                        _collection.add(_editedDeck);
                      } else {
                        // just update the Deck in the collection -- it will
                        // take care of notifying its listeners
                        _collection.update(widget.deckIndex!, _editedDeck);
                        }
                      Navigator.of(context).pop();
                    },
                  ),
                  if(!widget.isNewDeck)
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        _collection.remove(widget.deckIndex!);
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