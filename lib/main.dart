import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Memory Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const CardGridPage(),
      ),
    );
  }
}

class CardModel {
  final String frontImage;
  final String backImage;
  bool isFaceUp;

  CardModel({
    required this.frontImage,
    required this.backImage,
    this.isFaceUp = false,
  });
}

class GameState extends ChangeNotifier {
  final int gridSize = 4; // 4x4 Grid (Total 16 cards)
  late List<CardModel> cards;
  List<int> flippedIndexes = [];

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<String> images = [
      'assets/images/card_1.png',
      'assets/images/card_2.png',
      'assets/images/card_3.png',
      'assets/images/card_4.png',
      'assets/images/card_5.png',
      'assets/images/card_6.png',
      'assets/images/card_7.png',
      'assets/images/card_8.png',
    ];

    // Create pairs and shuffle
    List<CardModel> cardPairs = [];
    for (var image in images) {
      cardPairs.add(CardModel(frontImage: image, backImage: 'assets/images/card_back.png'));
      cardPairs.add(CardModel(frontImage: image, backImage: 'assets/images/card_back.png'));
    }
    cardPairs.shuffle(Random()); // Shuffle the pairs

    // Assign to game state
    cards = cardPairs;
    notifyListeners();
  }

  void flipCard(int index) {
    if (flippedIndexes.length == 2 || cards[index].isFaceUp) return;

    cards[index].isFaceUp = true;
    flippedIndexes.add(index);

    if (flippedIndexes.length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        _checkMatch();
      });
    }

    notifyListeners();
  }

  void _checkMatch() {
    if (cards[flippedIndexes[0]].frontImage == cards[flippedIndexes[1]].frontImage) {
      // Matching pair found, keep face-up
      flippedIndexes.clear();
    } else {
      // No match, flip back down
      for (var index in flippedIndexes) {
        cards[index].isFaceUp = false;
      }
      flippedIndexes.clear();
    }
    notifyListeners();
  }
}


class CardGridPage extends StatelessWidget {
  const CardGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the size of each card to fill the screen and double the size
            double cardSize = (constraints.maxWidth - (gameState.gridSize + 1) * 8) / gameState.gridSize;
            cardSize *= 4; // Double the card size

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameState.gridSize,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: gameState.cards.length,
              itemBuilder: (context, index) {
                final card = gameState.cards[index];
                return GestureDetector(
                  onTap: () => gameState.flipCard(index),
                  child: Container(
                    width: cardSize, // Set the width dynamically
                    height: cardSize, // Set the height dynamically
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(card.isFaceUp ? card.frontImage : card.backImage),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


