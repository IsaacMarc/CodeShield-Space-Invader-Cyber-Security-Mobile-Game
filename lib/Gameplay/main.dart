import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/difficulty_selection.dart'; // Ensure you import your new screen
import 'package:codeshield/screens/main_menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // Change 'home' to your selection screen. 
      // This is the "Entry Point" of your app.
      home: const DifficultySelectionScreen(loggedInUser: "GUEST"), 
    ),
  );
}

// --- OVERLAY BUILDERS ---
// Keep these here! Your DifficultySelectionScreen will reference these 
// when it eventually builds the GameWidget.

Widget pauseButtonBuilder(BuildContext context, SpaceShooterGame game) {
  return Positioned(
    top: 20,
    left: 20,
    child: GestureDetector(
      onTap: () {
        game.pauseEngine();
        game.overlays.add('PauseMenu');
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26, // Adds a slight shadow so it's visible over any background
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.pause_rounded, // Built-in Flutter Icon
          color: Colors.white,
          size: 40,
        ),
      ),
    ),
  );
}

Widget pauseMenuBuilder(BuildContext context, SpaceShooterGame game) {
return Material(
    type: MaterialType.transparency, // Keeps it see-through
    child: Stack(
      children: [
        Container(color: Colors.black54),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
            Text('SCORE: ${game.score}', 
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'PixelifySans',)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                game.resumeEngine();
                game.overlays.remove('PauseMenu');
              },
              child: const Text('RESUME', style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'PixelifySans')),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                game.overlays.remove('PauseMenu');
                game.resetGame();
              },
              child: const Text('RETRY', style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'PixelifySans')),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                game.overlays.remove('PauseMenu');
                // Pass the player's name back to the MainMenu
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainMenu(loggedInUser: game.playerName))
                );
              },
              child: const Text('EXIT MAIN MENU', style: TextStyle(color: Colors.red, fontSize: 24, fontFamily: 'PixelifySans')),
            ),
            const SizedBox(height: 30),
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      "MUTE MUSIC", 
      style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'PixelifySans')
    ),
    const SizedBox(width: 20),
    
    StatefulBuilder(
      builder: (context, setInternalState) {
        return Checkbox(
          value: game.musicVolume == 0, // Checked if volume is 0
          activeColor: Colors.blueAccent,
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 2),
          onChanged: (bool? isMuted) {
            setInternalState(() {
              if (isMuted == true) {
                game.setMusicVolume(0.0); // Mute
              } else {
                game.setMusicVolume(0.5); // Unmute to 50%
              }
            });
          },
        );
      },
    ),
  ],
)
          ],
        ),
      ),
    ],
  ));
}

Widget gameOverBuilder(BuildContext context, SpaceShooterGame game) {
return Material(
    type: MaterialType.transparency,
    child: Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('SYSTEM COMPROMISED', 
              style: TextStyle(color: Color.fromARGB(255, 192, 13, 0), fontSize: 40, fontWeight: FontWeight.bold,fontFamily: 'PixelifySans')),
          const SizedBox(height: 20),
          Text('FINAL SCORE: ${game.score}', 
              style: const TextStyle(color: Colors.white, fontSize: 24,fontFamily: 'PixelifySans')),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () {
              game.overlays.remove('GameOver');
              game.resumeEngine();
              game.resetGame();
            },
            child: const Text('RETRY', style: TextStyle(color: Colors.white, fontSize: 30,fontFamily: 'PixelifySans')),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Pass the player's name back to the Difficulty Selection
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => DifficultySelectionScreen(loggedInUser: game.playerName))
              );
            },
            child: const Text('GO TO MAIN MENU', style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'PixelifySans')),
          ),
        ],
      ),
    ),
  ));
}

Widget upgradeMenuBuilder(BuildContext context, SpaceShooterGame game) {
void refresh() {
    game.overlays.remove('UpgradeMenu');
    game.overlays.add('UpgradeMenu');
  }

  // WRAP EVERYTHING IN MATERIAL
  return Material(
    type: MaterialType.transparency, // This keeps the background see-through
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 600,
        color: Colors.black.withOpacity(0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Text('POINTS AVAILABLE: ${game.upgradePoints}', 
            style: const TextStyle(color: Colors.yellow, fontSize: 20,fontFamily: 'PixelifySans')),
          const Divider(color: Colors.white),
          
          _upgradeRow('Shotgun', game.shotgunLevel, () {
            if (game.upgradePoints > 0 && game.shotgunLevel < 5) {
              game.shotgunLevel++;
              game.upgradePoints--;
              game.player.updateFireRateForWeapon(); 
              refresh(); 
            }
          }),
          
          _upgradeRow('Single Shot', game.singleShotLevel, () {
            if (game.upgradePoints > 0 && game.singleShotLevel < 4) {
              game.singleShotLevel++;
              game.upgradePoints--;
              game.player.updateFireRateForWeapon(); 
              refresh();
            }
          }),

          _upgradeRow('Stun Gun', game.stunLevel, () {
            if (game.upgradePoints > 0 && game.stunLevel < 4) {
              game.stunLevel++;
              game.upgradePoints--;
              refresh();
            }
          }),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => game.overlays.remove('UpgradeMenu'),
            child: const Text('CLOSE', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontFamily: 'PixelifySans'),),
          )
        ],
      ),
    ),
  ));
}

Widget _upgradeRow(String label, int level, VoidCallback onAdd) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label (Lv $level)', style: const TextStyle(color: Colors.white,fontFamily: 'PixelifySans')),
        GestureDetector(
          onTap: onAdd,
          child: const Icon(Icons.add_box, color: Color.fromARGB(255, 255, 255, 255), size: 30),
        ),
      ],
    ),
  );
}