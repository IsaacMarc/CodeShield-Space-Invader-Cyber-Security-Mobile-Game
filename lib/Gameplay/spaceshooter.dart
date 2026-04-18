import 'package:codeshield/Gameplay/EnemyConfig/boss.dart';
import 'package:codeshield/Gameplay/Weapons/bullet.dart';
import 'package:codeshield/Gameplay/Weapons/honeypotdecoy.dart';
import 'package:codeshield/Gameplay/explosion.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:codeshield/Gameplay/player.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy.dart';
import 'package:codeshield/Gameplay/home_base.dart';
import 'package:codeshield/Gameplay/scorehud.dart';
import 'dart:math'; 
import 'package:codeshield/Gameplay/EnemyConfig/enemy_database.dart';
import 'package:codeshield/Gameplay/Weapons/scan_wave.dart';
import 'package:codeshield/Gameplay/health_bar.dart';
import 'package:codeshield/Gameplay/wave_manager.dart';
import 'package:codeshield/Gameplay/wave_announcement.dart';
import 'package:codeshield/Gameplay/Weapons/powerup.dart';
import 'package:codeshield/Gameplay/Weapons/firewall.dart';
import 'package:hive/hive.dart';
import 'package:flame_audio/flame_audio.dart';

enum WeaponType { standard, shotgun, stun }
enum GameDifficulty { normal, hard }

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
    
  final GameDifficulty difficulty;
  final String playerName;

  SpaceShooterGame({
    required this.difficulty,
    required this.playerName,
  });

  late Player player;
  WeaponType currentWeapon = WeaponType.standard;
  late SpriteButtonComponent shotgunToggle;
  late HomeBase homebase;
  late WaveManager waveManager;
  
  int basehealth = 100;
  int score = 0; 
  late ScoreBoard _scoreBoard;
  late HomeBaseHealth _baseHealth;
  late HealthBar healthBar;
  late TextComponent waveUI;
  Color bulletColor = Colors.white;
  double musicVolume = 0.1; // Default 50%

  final _random = Random();

  late SpriteGroupComponent<bool> upgradeButton;
  int upgradePoints = 0;
  int shotgunLevel = 0;
  int singleShotLevel = 0;
  int stunLevel = 0;

  void resetUpgrades() {
    upgradePoints = 0;
    shotgunLevel = 0;
    singleShotLevel = 0;
    stunLevel = 0;
  }

  void _updatePersistenceHighScore() {
    if (playerName == "GUEST") return;
    final userBox = Hive.box('userBox');
    var userData = userBox.get(playerName);
    if (userData != null) {
      int existingHighScore = userData['highscore'] ?? 0;
      if (score > existingHighScore) {
        userData['highscore'] = score;
        userBox.put(playerName, userData);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    upgradeButton.current = upgradePoints > 0;
    
    if (basehealth <= 0) {
      pauseEngine(); 
      if (!overlays.activeOverlays.contains('GameOver')) {
        _updatePersistenceHighScore(); 
        overlays.add('GameOver'); 
      }
    }
  }

  @override
  Future<void> onLoad() async {

    await FlameAudio.audioCache.loadAll([
      'laser.mp3', 'enemy die.wav', 'scan.wav', 'stun.wav'
    ]);

    // 2. Start the appropriate music
    playBackgroundMusic();

    // 1. Parallax Background - Horizontal movement for Landscape
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('Background.png')], 
      baseVelocity: Vector2(40, 0), 
      repeat: ImageRepeat.repeat,
    );
    add(parallax);
    
        debugMode = false;
    add(FpsTextComponent(
      position: Vector2(10, 10), 
      anchor: Anchor.topLeft,
       
    ));

    homebase = HomeBase(); 
    add(homebase);

    healthBar = HealthBar();
    add(healthBar);

    _scoreBoard = ScoreBoard(); 
    add(_scoreBoard);

    _baseHealth = HomeBaseHealth(); 
    add(_baseHealth);

    player = Player();
    add(player); 

    waveUI = TextComponent(
      text: 'OSI Layer: Initialize...',
      position: Vector2(520, 22), 
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(style: const TextStyle(
        color: Colors.white, 
        fontSize: 18, 
        fontFamily: 'PixelifySans'
      )),
    );
    add(waveUI);

    waveManager = WaveManager();
    add(waveManager);

    // --- RESPONSIVE LANDSCAPE BUTTONS ---
    // On landscape, height (y) is the constraint for button sizing
    final double btnSize = size.y * 0.22; 
    final double spacing = 15.0;         
    final double marginX = 30.0;         
    final double bottomMargin = 25.0;    

    // --- ACTION BUTTONS (Aligned Horizontally Bottom-Right) ---
    
    // Scanner
    add(SpriteButtonComponent(
      button: await loadSprite('scanner_unpressed.png'), 
      buttonDown: await loadSprite('scanner_pressed.png'),
      position: Vector2(size.x - btnSize - marginX, size.y - btnSize - bottomMargin), 
      size: Vector2(btnSize, btnSize),
      onPressed: () {
         add(ScanWave(position: Vector2(player.position.x, 0)));
         add(ScanWave(position: Vector2(player.position.x - 20, 0))..paint.color = Colors.cyan.withOpacity(0.3));
         FlameAudio.play('scan.wav',volume: musicVolume);
      },
    ));

    // Stun
    add(SpriteButtonComponent(
      button: await loadSprite('stun_unpressed.png'),
      buttonDown: await loadSprite('stun_pressed.png'),
      position: Vector2(size.x - (btnSize * 2) - marginX - spacing, size.y - btnSize - bottomMargin), 
      size: Vector2(btnSize, btnSize),
      onPressed: () {
        player.fireStunProjectile();
        FlameAudio.play('stun.wav',volume: musicVolume);},
    ));

    // Shotgun Toggle
    shotgunToggle = SpriteButtonComponent(
      button: await loadSprite('single_shot_unpressed.png'), 
      buttonDown: await loadSprite('single_shot_pressed.png'),
      position: Vector2(size.x - (btnSize * 3) - marginX - (spacing * 2), size.y - btnSize - bottomMargin), 
      size: Vector2(btnSize, btnSize),
      onPressed: () async {
        if (currentWeapon == WeaponType.standard) {
          currentWeapon = WeaponType.shotgun;
          player.updateFireRateForWeapon(); 
          shotgunToggle.button = await loadSprite('shotgun_unpressed.png');
          shotgunToggle.buttonDown = await loadSprite('shotgun_pressed.png');
        } else {
          currentWeapon = WeaponType.standard;
          player.updateFireRateForWeapon(); 
          shotgunToggle.button = await loadSprite('single_shot_unpressed.png');
          shotgunToggle.buttonDown = await loadSprite('single_shot_pressed.png');
        }
      },
    );
    add(shotgunToggle);

    // --- UPDATE BUTTON (Centered on HomeBase Pillar) ---
    final double upgradeWidth = btnSize * 1.5; 
    final double upgradeHeight = btnSize * 0.5;

    upgradeButton = SpriteGroupComponent<bool>(
      // x is centered on the HomeBase (HomeBase width is 80)
      position: Vector2(50 - (upgradeWidth / 2), size.y - upgradeHeight - bottomMargin),
      size: Vector2(upgradeWidth, upgradeHeight),
      sprites: {
        false: await loadSprite('update_normal.png'),
        true: await loadSprite('update_alert.png'),
      },
      current: false,
    );

    upgradeButton.add(
      _UpgradeButtonSensor(
        size: upgradeButton.size,
        onPressed: () => overlays.add('UpgradeMenu'),
      ),
    );

    add(upgradeButton);
  }
  
  void showWaveAnnouncement(String message) {
    waveUI.text = message;
    add(WaveAnnouncement(text: message));
  }
  
  @override void onPanUpdate(DragUpdateInfo info) => player.move(info.delta.global);
  @override void onPanStart(DragStartInfo info) => player.startShooting();
  @override void onPanEnd(DragEndInfo info) => player.stopShooting();

  void spawnEnemy(EnemyType type) {
    final config = enemyRegistry[type];
    if (config != null) {
      // --- SPAWN PADDING LOGIC ---
      const double edgePadding = 40.0; // Keeps enemies 40px away from top/bottom
      
      // Calculate a random Y that is at least 'edgePadding' and at most 'Height - edgePadding'
      final double randomY = edgePadding + (_random.nextDouble() * (size.y - (edgePadding * 2)));

      add(Enemy(
        config: config, 
        type: type, 
        // Spawn them slightly off-screen to the right (size.x + 50) 
        // but within our Y-axis safe zone
        position: Vector2(size.x + 50, randomY), 
      ));
    }
  }

  void spawnEnemyAt(EnemyType type, Vector2 spawnPos) {
    final config = enemyRegistry[type];
    if (config != null) add(Enemy(config: config, type: type, position: spawnPos));
  }

  void applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.fireRate:
        player.updateFireRate(0.5); 
        Future.delayed(const Duration(seconds: 5), () => player.updateFireRateForWeapon());
        break;
      case PowerUpType.mfaShield: homebase.activateMFAShield(); break;
      case PowerUpType.honeyPot:
        children.whereType<HoneyPotDecoy>().forEach((h) => h.removeFromParent());
        add(HoneyPotDecoy(position: Vector2(size.x * 0.8, size.y / 2)));
        break;
      case PowerUpType.totalReset:
        children.whereType<Enemy>().forEach((enemy) {
          enemy.removeFromParent();
          add(Explosion(position: enemy.position));
        });
        score += 500;
        break;
      case PowerUpType.firewall: add(FirewallWall(position: Vector2(0, 0))); break;
    }
  }

void resetGame() {
    basehealth = 100;
    score = 0;
    resetUpgrades(); 
    healthBar.updateHealth(basehealth);

    // 1. CLEAR UI GHOSTS (This fixes the overlapping text)
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<BossFight>().forEach((boss) => boss.removeFromParent());
    children.whereType<WaveAnnouncement>().forEach((a) => a.removeFromParent()); // Clear old text!

    // 2. CLEAN RESET OF WAVE MANAGER
    // Don't call onMount() or set variables here. Just replace it.
    waveManager.removeFromParent(); 
    waveManager = WaveManager(); 
    add(waveManager); // This automatically triggers the first wave correctly

    // 3. RESET PLAYER
    player.position = Vector2(150, size.y / 2); // Standard start position
    
    resumeEngine();
  }


void playBackgroundMusic() {
    FlameAudio.bgm.stop(); // Stop any current music
    
    if (difficulty == GameDifficulty.hard) {
      FlameAudio.bgm.play('hardmusic.mp3', volume: musicVolume);
    } else {
      FlameAudio.bgm.play('normalmusic.ogg', volume: musicVolume);
    }
  }

void setMusicVolume(double newVolume) {
    // Clamp ensures volume stays between 0.0 (mute) and 1.0 (max)
    musicVolume = newVolume.clamp(0.0, 0.1);
    FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
  }
    }

class _UpgradeButtonSensor extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  _UpgradeButtonSensor({required Vector2 size, required this.onPressed,}) : super(size: size);
  @override void onTapDown(TapDownEvent event) => onPressed();
}