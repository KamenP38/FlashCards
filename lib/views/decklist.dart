import 'package:flutter/material.dart';

class DeckList extends StatelessWidget {
  const DeckList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(4),
        children: List.generate(3, (index) => 
          Card(
            color: Colors.purple[100],
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  InkWell(onTap: () {
                    print('Deck ${index + 1} tapped');
                  }),
                  Center(child: Text('Deck ${index + 1}')),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        print('Deck ${index + 1} edited');
                      },
                    ),
                  ),
                ],
              )
            )
          )
        )
      )
    );
  }
}
