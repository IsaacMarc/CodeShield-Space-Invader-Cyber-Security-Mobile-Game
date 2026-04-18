import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/Weapons/bullet.dart';
import 'package:codeshield/Gameplay/Weapons/stun_round.dart';
import 'dart:async';

class Player extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> {
  late final SpawnComponent _bulletSpawner;

  // Reduced size slightly for mobile to make the game feel larger
  Player() : super(size: Vector2(80, 80), anchor: Anchor.center);

  int stunCharges = 2; 
  double stunRechargeTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // --- STUN RECHARGE LOGIC ---
    int maxCharges = (game.stunLevel >= 4) ? 3 : 2;
    if (stunCharges < maxCharges) {
      stunRechargeTimer += dt;
      double currentRechargeRate = (game.stunLevel >= 1) ? 1.0 : 4.0;

      if (stunRechargeTimer >= currentRechargeRate) {
        stunCharges++;
        stunRechargeTimer = 0;
      }
    }

    // --- SCREEN BOUNDARY CLAMPING (Mobile Fix) ---
    // This keeps the ship from going off the edges of the Tecno Camon screen
    final halfSize = size / 2;
    position.x = position.x.clamp(halfSize.x, game.size.x - halfSize.x);
    position.y = position.y.clamp(halfSize.y, game.size.y - halfSize.y);
  }

void fireStunProjectile() {
  // Check cooldown based on upgrades (Lv 1+ reduces cooldown to 1s)
double stunInterval = (game.stunLevel >= 1) ? 1.0 : 4.0; 
  
  if (stunRechargeTimer >= stunInterval || stunCharges > 0) {
    final spawnPos = position.clone() + Vector2(size.x / 1.5, 0);

    // --- SPREAD LOGIC ---
    int bulletCount = 1; // Base & Lv 1 & Lv 2
    if (game.stunLevel == 3) bulletCount = 3; // Level 3: 3 bullet spread
    if (game.stunLevel >= 4) bulletCount = 5; // Level 4 (Max): 5 bullet spread

    // If we have a spread upgrade (Lv 3 or 4)
    if (bulletCount > 1) {
      for (int i = 0; i < bulletCount; i++) {
        // Spread the stun rounds vertically
        // For 3 bullets: -150, 0, 150
        // For 5 bullets: -200, -100, 0, 100, 200
        double yVelocity = (i - (bulletCount - 1) / 2) * 150;

        game.add(StunRound(
          position: spawnPos.clone(),
          // Ensure your StunRound class can handle velocity/direction
          // If it only moves right, you'll need to update StunRound to use this velocity
        )..velocity = Vector2(600, yVelocity)); 
      }
    } else {
      // Standard single shot for Levels 0, 1, and 2
      game.add(StunRound(position: spawnPos));
    }

    stunCharges--;
    stunRechargeTimer = 0;
  }
}

  // Helper to sync fire rate with current upgrades
  void updateFireRateForWeapon() {
    _bulletSpawner.timer.stop();

    if (game.currentWeapon == WeaponType.shotgun) {
    double waitTime = 3.0; 
    if (game.shotgunLevel >= 3) waitTime = 2.0;
    if (game.shotgunLevel >= 5) waitTime = 1.0; 
    
    _bulletSpawner.period = waitTime;
  } else {
    double rate = 0.8; 
    if (game.singleShotLevel == 1) rate = 0.5;
    if (game.singleShotLevel == 2) rate = 0.3;
    if (game.singleShotLevel == 3) rate = 0.15;
    if (game.singleShotLevel >= 4) rate = 0.05; 
    
    _bulletSpawner.period = rate;
  }

  // Restart the timer only if the player is currently holding the screen
  // This prevents the gun from shooting by itself after a toggle
  _bulletSpawner.timer.start();
  }

  void updateFireRate(double newPeriod) {
    _bulletSpawner.period = newPeriod;
  }

  void _fireWeapon() {
    final spawnPos = position.clone() + Vector2(size.x / 2, 0);

    if (game.currentWeapon == WeaponType.shotgun) {
      int burstCount = (game.shotgunLevel >= 4) ? 3 : (game.shotgunLevel >= 2 ? 2 : 1);

      for (int b = 0; b < burstCount; b++) {
        Future.delayed(Duration(milliseconds: b * 200), () {
          if (!isMounted) return;
          
          // --- 1. PLAY SHOTGUN BURST SOUND ---
          // Placing it here makes it play every 200ms with the burst

          for (int i = 0; i < 5; i++) {
            double ySpread = (i - 2) * 80; 
            game.add(Bullet(position: spawnPos.clone(), velocity: Vector2(800, ySpread)));
          }
        });
      }
    } else if (game.currentWeapon == WeaponType.standard) {
      double bulletSpeed = (game.singleShotLevel >= 4) ? 1200 : 800;
      game.add(Bullet(position: spawnPos.clone(), velocity: Vector2(bulletSpeed, 0)));
    }
  }

  @override
  Future<void> onLoad() async {
    
    await super.onLoad();
    

    animation = await game.loadSpriteAnimation(
      'playerplayer.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(256, 256), 
      ),
    );

    add(RectangleHitbox());
    
    // Start in the lower middle - better ergonomics for thumbs
    position = Vector2(game.size.x / 4, game.size.y * 0.7);

    _bulletSpawner = SpawnComponent(
      period: 0.8,
      factory: (index) {
        _fireWeapon();
        return PositionComponent(); 
      },
      selfPositioning: true,
      autoStart: false,
    );

    game.add(_bulletSpawner);
  }

  void startShooting() {
    if (_bulletSpawner.timer.current >= _bulletSpawner.period || !_bulletSpawner.timer.isRunning()) {
      _fireWeapon();
    }
    _bulletSpawner.timer.start();
  }
  
  void stopShooting() => _bulletSpawner.timer.stop();

  // Mobile Movement: Add a sensitivity multiplier if needed
  void move(Vector2 delta) {
    position.add(delta);
  }
}