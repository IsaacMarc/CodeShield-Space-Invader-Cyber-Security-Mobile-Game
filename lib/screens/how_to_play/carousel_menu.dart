import 'package:carousel_slider/carousel_slider.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/carousel_data.dart';
import 'package:codeshield/widgets/game_app_bar.dart';
import 'package:codeshield/screens/how_to_play/carousel_item.dart';
import 'package:flutter/material.dart';

class HowToPlayMenu extends StatefulWidget {
  const HowToPlayMenu({super.key});

  @override
  State<HowToPlayMenu> createState() => _HowToPlayMenuState();
}

class _HowToPlayMenuState extends State<HowToPlayMenu> {
  int _currentIndex = 0;
  
  final List<CarouselItemData> tutorialData = [
    CarouselItemData(color: Colors.blue, title: "MOVEMENT / GAMEPLAY", videoPath: "assets/videos/movement_gameplay.mp4", details: "Drag the player all across the screen to move and shoot the upcoming enemies.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
    CarouselItemData(color: Colors.blueAccent, title: "OBJECTIVE", videoPath: "assets/videos/objective.mp4", details: "Cyber threats are coming from the right to attack your home server. Protect it using your abilities.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
    CarouselItemData(color: Colors.blueGrey, title: "WAVE LOGIC", videoPath: "assets/videos/wavelogic.mp4", details: "Each wave represents an OSI Layer from 3 to 7 with exclusive cyberattack enemies.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
    CarouselItemData(color: Colors.orange, title: "POWER-UP DROPS", videoPath: "assets/videos/powerups.mp4", details: "Enemies drop power-ups to help eliminate threats or protect your central server.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
    CarouselItemData(color: Colors.purple, title: "WEAPON TYPES", videoPath: "assets/videos/weapon_type.mp4", details: "Use Single/Burst, Stun, and Scanner abilities to counter specific cyber attacks.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
    CarouselItemData(color: Colors.purple, title: "UPGRADES", videoPath: "assets/videos/upgrade.mp4", details: "Upgrade your weapons after every wave using points provided for successful defense.",longDescription: "",threatlevel: "",vulnerability: "",osilayer: "",protocol: ""),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // --- FIX: CALCULATE DYNAMIC WIDTH ---
    double targetHeight = screenHeight * 0.30; 
    double targetWidth = targetHeight * (16 / 9); // Force 16:9 ratio
    double dynamicFraction = targetWidth / screenWidth;

    final carouselItems = tutorialData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return HowToPlayVideoItem(data: data, isActive: _currentIndex == index);
    }).toList();

    final carouselSlider = CarouselSlider(
      options: CarouselOptions(
        height: targetHeight, 
        autoPlay: false,
        enlargeCenterPage: true,
        // This ensures the container width matches the video width
        viewportFraction: dynamicFraction.clamp(0.1, 0.9), 
        onPageChanged: (index, reason) => setState(() => _currentIndex = index),
      ),
      items: carouselItems,
    );

    return Scaffold(
      appBar: const MenuAppBar(),
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset(AppImages.menuBackgroundAlt, fit: BoxFit.cover)),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  carouselSlider,
                  const SizedBox(height: 40),
                  _buildDescriptionText(screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? screenWidth * 0.2 : 24.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey<int>(_currentIndex),
          children: [
            Text(tutorialData[_currentIndex].title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'PixelifySans')),
            const SizedBox(height: 12),
            Text(tutorialData[_currentIndex].details, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'PixelifySans')),
            const SizedBox(height: 16),
            const Text("(Tap the highlighted video to play/pause)", style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontFamily: 'PixelifySans')),
          ],
        ),
      ),
    );
  }
}