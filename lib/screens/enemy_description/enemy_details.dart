import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_fonts.dart';
import 'package:codeshield/core/carousel_data.dart';
import 'package:codeshield/widgets/game_app_bar.dart';
import 'package:flutter/material.dart';

class EnemyDetails extends StatelessWidget {
  const EnemyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Safety check for null data with failure-graceful UI
    if (args == null || args is! CarouselItemData) {
      return Scaffold(
        appBar: const MenuAppBar(),
        body: Center(
          child: Text(
            "CRITICAL ERROR: THREAT DATA CORRUPTED",
            style: TextStyle(
              color: Colors.redAccent,
              fontFamily: AppFonts.main,
              fontSize: 24,
            ),
          ),
        ),
      );
    }

    final data = args;

    return Scaffold(
      appBar: const MenuAppBar(),
      body: Stack(
        children: [
          // Background Layer
          SizedBox.expand(
            child: Image.asset(AppImages.menuBackgroundAlt, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: The Framed Sprite (Hero)
                  // Constrained to maintain the 600x800 aspect ratio (3:4)
                  Hero(
                    tag: 'carousel_hero_${data.title}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        height: 300, // Fixed height for landscape mobile
                        width: 225,  // Proportional width (3/4 of height)
                        decoration: BoxDecoration(
                          color: data.color ?? Colors.black,
                          border: Border.all(color: Colors.white, width: 25.0), // Your signature border
                          image: data.imagePath != null
                              ? DecorationImage(
                                  image: AssetImage(data.imagePath!),
                                  fit: BoxFit.contain,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0, 
                              color: Colors.white, 
                              backgroundColor: Colors.black54,
                              fontFamily: AppFonts.main,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  // Right Side: Intelligence Dossier (Scrollable)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "INTEL REPORT: ${data.title}",
                          style: const TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                            fontFamily: AppFonts.main,
                          ),
                        ),
                        const Divider(color: Colors.white, thickness: 2),
                        const SizedBox(height: 10),
                        
                        // Scrollable Information Area
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.subtitle ?? "Classified Malware Signature",
                                  style: const TextStyle(
                                    fontSize: 18, 
                                    color: Colors.cyanAccent, 
                                    fontStyle: FontStyle.italic,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Abundant Information Text
                                Text(
                                  data.longDescription,
                                  style: const TextStyle(
                                    fontSize: 16.0, 
                                    height: 1.6, 
                                    color: Colors.white,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),
                                
                                const SizedBox(height: 30),
                                
                               Text(
                                  data.threatlevel,
                                  style: const TextStyle(
                                    fontSize: 16.0, 
                                    height: 1.6, 
                                    color: Colors.red,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),
                                                               Text(
                                  data.osilayer,
                                  style: const TextStyle(
                                    fontSize: 16.0, 
                                    height: 1.6, 
                                    color: Colors.blue,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),

                                                               Text(
                                  data.protocol,
                                  style: const TextStyle(
                                    fontSize: 16.0, 
                                    height: 1.6, 
                                    color: Colors.orange,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),

                                                               Text(
                                  data.vulnerability,
                                  style: const TextStyle(
                                    fontSize: 16.0, 
                                    height: 1.6, 
                                    color: Colors.green,
                                    fontFamily: AppFonts.main,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        
                        
                      ],
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