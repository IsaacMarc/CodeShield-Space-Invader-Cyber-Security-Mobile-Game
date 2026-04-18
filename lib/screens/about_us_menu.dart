import 'package:flutter/material.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_text_styles.dart';
import 'package:codeshield/widgets/game_app_bar.dart';

class AboutUsMenu extends StatelessWidget {
  const AboutUsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Wrap instead of a Row to allow items to flow to the next line
    Widget dpGrid = Wrap(
      spacing: 20, // Horizontal space between cards
      runSpacing: 20, // Vertical space between lines
      alignment: WrapAlignment.center,
      children: [
        _buildDeveloperCard("Isaac Marcus Santos", AppImages.dpIsaac),
        _buildDeveloperCard("Emmanuel Cerafica", AppImages.dpEmman),
        _buildDeveloperCard("Carl Nueva", AppImages.dpCarl),
        _buildDeveloperCard("Airamei Lindo", AppImages.dpAira),
      ],
    );

    Widget scrollView = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("ABOUT", style: AppTextStyles.titleText.copyWith(fontSize: 28)),
          const SizedBox(height: 16),
          Text(
            "A mobile learning app that inspires to learn cybersecurity "
            "education through an arcade style defense game inspired by "
            "the 1978 Retro Arcade Game Space Invaders. The user will take "
            "the role as the Cyber Guardian where the task is to defend "
            "the central network server from waves of invading ships "
            "representing incoming cyber-attacks." " Each waves of attack represent different layers that you the player will use different solutions to beat them.",
            style: AppTextStyles.bodyText.copyWith(fontSize: 14),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 40),
          Text("DEVELOPERS", style: AppTextStyles.titleText.copyWith(fontSize: 24)),
          const SizedBox(height: 20),
          dpGrid,
          const SizedBox(height: 40),
        ],
      ),
    );

    return Scaffold(
      appBar: const MenuAppBar(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(AppImages.menuBackgroundFull, fit: BoxFit.cover),
          ),
          SafeArea(child: scrollView),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "Made by the students of the\nTechnological Institute of the Philippines",
          style: AppTextStyles.bodyText.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper method to build individual dev cards
  Widget _buildDeveloperCard(String name, String assetPath) {
    return SizedBox(
      width: 140, // Fixed width for each "Index Card"
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              height: 140,
              width: 140,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.profileText.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}