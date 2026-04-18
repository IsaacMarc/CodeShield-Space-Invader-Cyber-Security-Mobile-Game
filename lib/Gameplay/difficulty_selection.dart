import 'package:codeshield/Gameplay/main.dart';
import 'package:codeshield/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart'; // Import your enum
import 'package:flame/game.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final String loggedInUser; // Add this
  const DifficultySelectionScreen({super.key, required this.loggedInUser}); // Update this
  @override
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  String selected = "none"; // "none", "normal", or "hard"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Grid (Use a Repeatable Image or CustomPainter)
          const Positioned.fill(child: GridBackground()),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('DIFFICULTY', 
                  style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 4,fontFamily: 'PixelifySans')),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- NORMAL CHOICE ---
                    _buildDifficultyCard(
                      id: "normal",
                      title: "NORMAL",
                      color: Colors.white,
                      image: 'assets/images/virus_green.png',
                      bullets: ["No changes in:", "• Enemy Spawn Rate", "• Powerup Drops", "• Enemy Speed"],
                      difficulty: GameDifficulty.normal,
                    ),
                    const SizedBox(width: 40),
                    // --- HARD CHOICE ---
                    _buildDifficultyCard(
                      id: "hard",
                      title: "HARD",
                      color: Colors.red,
                      image: 'assets/images/virus_red.png',
                      bullets: ["CHANGES:","• INCREASED ENEMIES", "• DECREASED POWERUP DROPS", "• INCREASED ENEMY SPEED",],
                      difficulty: GameDifficulty.hard,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Back Button (Top Left)
        Positioned(
          top: 40,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MainMenu(loggedInUser: widget.loggedInUser) // Pass it back here
                )
              );
            },
          ),
        )
        ],
      ),
    );
  }

  Widget _buildDifficultyCard({
    required String id,
    required String title,
    required Color color,
    required String image,
    required List<String> bullets,
    required GameDifficulty difficulty,
  }) {
    bool isSelected = selected == id;

    return GestureDetector(
      onTap: () => setState(() => selected = id),
      child: Container(
        width: 350,
        height: 210,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5),
          color: Colors.black,
        ),
        child: isSelected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...bullets.map((b) => Text(b, style: const TextStyle(color: Colors.white, fontSize: 16,fontFamily: 'PixelifySans'))),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                          // Inside DifficultySelectionScreen's Play Button
                          onPressed: () {
                            // Use the 'difficulty' parameter that was passed into this _buildDifficultyCard method
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => GameWidget(
                                game: SpaceShooterGame(difficulty: difficulty,playerName: widget.loggedInUser), // CHANGE 'chosenDifficulty' TO 'difficulty'
                                initialActiveOverlays: const ['PauseButton'],
                                overlayBuilderMap: {
                                  'PauseButton': (context, game) => pauseButtonBuilder(context, game as SpaceShooterGame),
                                  'PauseMenu': (context, game) => pauseMenuBuilder(context, game as SpaceShooterGame),
                                  'GameOver': (context, game) => gameOverBuilder(context, game as SpaceShooterGame),
                                  'UpgradeMenu': (context, game) => upgradeMenuBuilder(context, game as SpaceShooterGame),
                                },
                              ),
                            ));
                          },
                    child: const Text("PLAY", style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,fontFamily: 'PixelifySans')),
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image, height: 100),
                  const SizedBox(height: 10),
                  Text(title, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold,fontFamily: 'PixelifySans')),
                ],
              ),
      ),
    );
  }
}

// Simple Grid Background Widget
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GridPainter());
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}