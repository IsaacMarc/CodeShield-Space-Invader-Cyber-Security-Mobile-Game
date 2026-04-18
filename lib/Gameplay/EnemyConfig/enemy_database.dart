import 'package:codeshield/Gameplay/EnemyConfig/enemy.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'dart:math';

enum EnemyType { botnet, ransomware, phishing, malware, trojan, antivirus, sqlinjection, safeEmail }

final List<String> trojanSprites = [
    'installer1.png','installer2.png','installer3.png','installer4.png','installer5.png','installer6.png','installer7.png',
  ];

final List<String> antivirusSprites = [
    "antivirus1.png", "antivirus2.png", "antivirus3.png",
  ];

final List<String> virusSprites = [
    "virus_green.png", "virus_red.png", "virus_violet.png",
  ];

final Random random = Random();
String randomTrojan = trojanSprites[random.nextInt(trojanSprites.length)];
String randomAntivirus = antivirusSprites[random.nextInt(antivirusSprites.length)];
String randomVirus = virusSprites[random.nextInt(virusSprites.length)];


final Map<EnemyType, EnemyConfig> enemyRegistry = {
  EnemyType.botnet: EnemyConfig(
    spritePath: 'Botnets.png', // The organic blob
    frames: 4,                           // It has 6 animation frames
    stepTime: 0.1,
    textureSize: Vector2(64, 64),        // Size of ONE frame
    speed: 100,
  ),
  EnemyType.sqlinjection: EnemyConfig(
    spritePath: 'SQLinjection.png',      // The red skull bot
    frames: 2,
    stepTime: 0.1,
    textureSize: Vector2(128, 128),
    speed: 100,
  ),
  EnemyType.malware: EnemyConfig(
    spritePath: 'virus_green.png',    
    frames: 2,          
    stepTime: 0.1,              
    textureSize: Vector2(128, 128),
    speed: 150,
  ),
  EnemyType.phishing: EnemyConfig(
    spritePath: 'normal email.png',   
    frames: 2,          
    stepTime: 0.1,               
    textureSize: Vector2(128, 128),
    speed: 150,
  ),
  EnemyType.trojan: EnemyConfig(
    spritePath: 'installer3.png',    
    frames: 1,          
    stepTime: 0.1,            
    textureSize: Vector2(128, 128),
    speed: 150,
  ),
  EnemyType.ransomware: EnemyConfig(
    spritePath: 'Ransomware.png',    
    frames: 2,          
    stepTime: double.infinity,              
    textureSize: Vector2(128, 128),
    speed: 50,
  ),
  EnemyType.antivirus: EnemyConfig(
    spritePath: 'antivirus1.png',    
    frames: 1,          
    stepTime: 0.1,            
    textureSize: Vector2(128, 128),
    speed: 150,
  ),
};

enum OSILayer { layer3, layer4, layer5, layer6, layer7, boss }

final Map<OSILayer, List<EnemyType>> layerEnemies = {
  OSILayer.layer3: [EnemyType.malware],
  OSILayer.layer4: [EnemyType.sqlinjection],
  OSILayer.layer5: [EnemyType.botnet],
  OSILayer.layer6: [EnemyType.ransomware],
  OSILayer.layer7: [EnemyType.phishing, EnemyType.trojan, EnemyType.antivirus],
  OSILayer.boss: [EnemyType.malware, EnemyType.sqlinjection, EnemyType.botnet, EnemyType.ransomware, 
  EnemyType.phishing, EnemyType.trojan]
};
