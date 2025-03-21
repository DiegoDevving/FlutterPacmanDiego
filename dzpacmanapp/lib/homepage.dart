import 'dart:async';
import 'dart:math';

import 'package:dzpacmanapp/path.dart';
import 'package:dzpacmanapp/pixel.dart';
import 'package:dzpacmanapp/player.dart';
import 'package:dzpacmanapp/ghost.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 17;
  int player = numberInRow * 15 + 1;
  int ghost = numberInRow * 1 + 1; // Starting position for ghost

  // Lists of indices for barriers and food.
  List<int> barriers = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 21, 22, 24, 26, 28, 30, 32,
    33, 35, 37, 38, 39, 41, 43, 44, 46, 52, 54, 55, 57, 59, 61, 63, 65,
    66, 70, 72, 76, 77, 78, 79, 80, 81, 83, 84, 85, 86, 87, 99, 100, 101,
    102, 103, 105, 106, 107, 108, 109, 110, 114, 116, 120, 121, 123,
    125, 127, 129, 131, 132, 134, 140, 142, 143, 145, 147, 148, 149, 151,
    153, 154, 156, 158, 160, 162, 164, 165, 175, 176, 177, 178, 179, 180,
    181, 182, 183, 184, 185, 186,
  ];
  List<int> food = [];

  // Movement variables.
  String direction = "right";       // Current moving direction
  String queuedDirection = "right"; // Last intended direction (from user input)
  bool preGame = true;
  bool mouthClosed = false;
  int score = 0;

  Timer? gameTimer;

  // Start the game by populating food, resetting positions, and starting the game loop.
  void startGame() {
    food.clear();
    getFood();
    score = 0;
    ghost = numberInRow * 1 + 1; // Reset ghost position
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        mouthClosed = !mouthClosed;
      });

      // Check if player is on a food cell.
      if (food.contains(player)) {
        food.remove(player);
        score++;
      }

      // If player collides with ghost, end the game.
      if (player == ghost) {
        timer.cancel();
        showGameOverDialog();
      }

      // Use queuedDirection if the move is possible.
      if (canMove(queuedDirection)) {
        direction = queuedDirection;
      }

      // Move the player in the current direction.
      switch (direction) {
        case "left":
          moveLeft();
          break;
        case "right":
          moveRight();
          break;
        case "up":
          moveUp();
          break;
        case "down":
          moveDown();
          break;
        default:
      }

      // Move ghost with simple random movement.
      moveGhost();
    });
  }

  // Populate food list with indices that are not barriers.
  void getFood() {
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  // Check if moving in a given direction is possible.
  bool canMove(String dir) {
    switch (dir) {
      case "left":
        return !barriers.contains(player - 1);
      case "right":
        return !barriers.contains(player + 1);
      case "up":
        return !barriers.contains(player - numberInRow);
      case "down":
        return !barriers.contains(player + numberInRow);
      default:
        return false;
    }
  }

  // Movement functions.
  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--;
      });
    }
  }
  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++;
      });
    }
  }
  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow;
      });
    }
  }
  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow;
      });
    }
  }

  // Simple ghost movement: randomly choose a direction that is not blocked.
  void moveGhost() {
    List<String> ghostDirections = ["left", "right", "up", "down"];
    ghostDirections.shuffle();
    for (String d in ghostDirections) {
      int newPosition = ghost;
      switch (d) {
        case "left":
          newPosition = ghost - 1;
          break;
        case "right":
          newPosition = ghost + 1;
          break;
        case "up":
          newPosition = ghost - numberInRow;
          break;
        case "down":
          newPosition = ghost + numberInRow;
          break;
      }
      if (!barriers.contains(newPosition)) {
        setState(() {
          ghost = newPosition;
        });
        break;
      }
    }
  }

  // Display a game over dialog and allow a restart.
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  preGame = true;
                  player = numberInRow * 15 + 1;
                });
              },
              child: Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Game Grid
          Expanded(
            flex: 5,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Update queuedDirection based on vertical drag.
                if (details.delta.dy > 0) {
                  queuedDirection = "down";
                } else if (details.delta.dy < 0) {
                  queuedDirection = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                // Update queuedDirection based on horizontal drag.
                if (details.delta.dx > 0) {
                  queuedDirection = "right";
                } else if (details.delta.dx < 0) {
                  queuedDirection = "left";
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    // Draw the player.
                    if (player == index) {
                      if (mouthClosed) {
                        return MyPlayer();
                      } else {
                        switch (direction) {
                          case "left":
                            return Transform.rotate(
                              angle: pi,
                              child: MyPlayer(),
                            );
                          case "right":
                            return MyPlayer();
                          case "up":
                            return Transform.rotate(
                              angle: 3 * pi / 2,
                              child: MyPlayer(),
                            );
                          case "down":
                            return Transform.rotate(
                              angle: pi / 2,
                              child: MyPlayer(),
                            );
                          default:
                            return MyPlayer();
                        }
                      }
                    }
                    // Draw the ghost.
                    else if (ghost == index) {
                      return MyGhost();
                    }
                    // Draw barriers.
                    else if (barriers.contains(index)) {
                      return MyPixel(
                        innerColor: Colors.blue[800],
                        outerColor: Colors.blue[900],
                      );
                    }
                    // Draw food cells if available; otherwise, render an empty path.
                    else {
                      if (food.contains(index)) {
                        return MyPath(
                          innerColor: Colors.yellow[400]!,
                          outerColor: Colors.black,
                        );
                      } else {
                        return const MyPath(
                          innerColor: Colors.black,
                          outerColor: Colors.black,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          // Score and Play Button Row
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Score: " + score.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (preGame) {
                        setState(() {
                          preGame = false;
                          startGame();
                        });
                      }
                    },
                    child: const Text(
                      "P L A Y",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
