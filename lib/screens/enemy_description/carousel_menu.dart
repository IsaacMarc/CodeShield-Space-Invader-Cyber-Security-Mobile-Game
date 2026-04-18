import 'package:carousel_slider/carousel_slider.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_fonts.dart';
import 'package:codeshield/core/carousel_data.dart';
import 'package:codeshield/widgets/game_app_bar.dart';
import 'package:flutter/material.dart';

class EnemyCarousel extends StatefulWidget {
  const EnemyCarousel({super.key});

  @override
  State<EnemyCarousel> createState() => _EnemyCarouselState();
}

class _EnemyCarouselState extends State<EnemyCarousel> {
  int _currentIndex = 0;

  final List<CarouselItemData> carouselData = [
    CarouselItemData(
      imagePath: 'assets/images/scanner template.png',
      title: "TROJAN",
      details: "Disguised malware providing unauthorized access.",
      // Adding the 'abundant information' here
      longDescription: 
          "A Trojan Horse is a type of malware that is often disguised as legitimate software. "
          "Trojans can be employed by cyber-thieves and hackers trying to gain access to users' systems. "
          "Unlike viruses and worms, Trojans do not self-replicate. They rely on social engineering "
          "to trick users into loading and executing them on their systems. Once activated, "
          "Trojans can enable cyber-criminals to spy on you, steal your sensitive data, and gain "
          "backdoor access to your system.",
      threatlevel: "Threat Level: High",
      osilayer: "OSI Layer: Layer 7 (Application)",
      protocol: "Protocol: SMTP (Email), FTP",
      vulnerability: "Vulnerability: Social Engineering. Trojans disguise themselves as legitimate software. The vulnerability is typically Lack of User Awareness, where a user executes an untrusted file thinking it is safe.",
      color: Colors.black,
    ),
    CarouselItemData(
    imagePath: 'assets/images/virus template.png',
    title: "MALWARE VIRUS",
    subtitle: "Category: Self-Replicating Code",
    details: "Malicious code that attaches to files to self-replicate.",
    longDescription: 
        "A computer virus is a type of malicious software that, when executed, replicates itself by modifying other computer programs and inserting its own code. \n\n"
        "Unlike a Worm, a virus requires a 'host' program or human intervention (like opening an infected email attachment) to spread. Once the host is executed, the virus payload can delete data, corrupt system files, or bypass security settings to install further backdoors.",
    threatlevel: "Threat Level: Medium",
      osilayer: "OSI Layer: Layer 3 (Network), Layer 7 (Application) ",
      protocol: "Protocol: HTTP/HTTPS, SMB",
      vulnerability: "Vulnerability: Insecure Software Downloads. Malware often exploits Buffer Overflows or Weak File Permissions to execute malicious code and replicate across the system.",
    color: Colors.black,
  ),
  CarouselItemData(
    imagePath: 'assets/images/botnet template.png',
    title: "BOTNETS",
    subtitle: "Category: Zombie Networks",
    details: "A network of 'zombie' computers controlled by a central actor.",
    longDescription: 
        "A botnet is a collection of internet-connected devices (PCs, servers, IoT devices) that are infected and controlled by a 'Bot Herder.' \n\n"
        "These infected devices, or 'zombies,' are used to perform massive-scale attacks, most notably Distributed Denial of Service (DDoS). By overwhelming a target server with traffic from thousands of different IP addresses simultaneously, the botnet makes the service unavailable to legitimate users.",
    threatlevel: "Threat Level: High",
    osilayer: "OSI Layer: Layer 5 (Session) , Layer 7 (Application)",
    protocol: "Protocol: TCP/UDP (for flooding), IRC/HTTP (for Command & Control).",
    vulnerability: "Vulnerability: Weak IoT Security & Default Credentials. Botnets often grow by scanning for Internet of Things (IoT) devices that still use default passwords (like admin/admin) or have unpatched firmware vulnerabilities.",
    color: Colors.black,
  ),
  CarouselItemData(
    imagePath: 'assets/images/phising template.png',
    title: "PHISHING",
    subtitle: "Category: Social Engineering",
    details: "Fraudulent communications used to steal sensitive credentials.",
    longDescription: 
        "Phishing is a cyber attack that uses disguised email, websites, or text messages as a weapon. The goal is to trick the recipient into believing that the message is something they want or need—a request from their bank, for instance—and clicking a link or downloading an attachment. \n\n"
        "This is the primary method used for initial access in most major cyber breaches. It exploits human psychology rather than technical software vulnerabilities.",
    threatlevel: "Threat Level: Low to High (depending on if it's Safe or Danger)",
    osilayer: "OSI Layer: Layer 7 (Application)",
    protocol: "Protocol: SMTP, IMAP, POP3",
    vulnerability: "Vulnerability: Identity Spoofing. Phishing exploits the Lack of Multi-Factor Authentication (MFA) and human error, tricking users into revealing credentials via spoofed communication.",
  
    color: Colors.black,
  ),
  CarouselItemData(
    imagePath: 'assets/images/sqlinjection template.png',
    title: "SQL INJECTION",
    subtitle: "Category: Injection Attack",
    details: "Malicious code insertion into backend database queries.",
    longDescription: 
        "SQL Injection (SQLi) is a web security vulnerability that allows an attacker to interfere with the queries that an application makes to its database. \n\n"
        "By entering malicious SQL statements into an entry field (like a login or search bar), an attacker can trick the application into executing commands it wasn't supposed to. This can result in unauthorized viewing of user data, the deletion of entire tables, or even administrative control over the database server.",
    threatlevel: "Threat Level: HIGH",
    osilayer: "Layer 4 (Transport), Layer 7 (Application)",
    protocol: "Protocol: HTTP, HTTPS, SQL",
    vulnerability: "Vulnerability: Poor Input Validation / Lack of Prepared Statements\n\n"
        "By exploiting the lack of input sanitization, an attacker can bypass authentication, view private user data, or even delete the entire database. This threat directly targets the Confidentiality and Integrity of the Information System.",
    color: Colors.black,
  ),
  CarouselItemData(
    imagePath: 'assets/images/ransomware template.png', // Ensure this matches your asset name
    title: "RANSOMWARE",
    subtitle: "Category: Cryptovirology / Availability Attack",
    details: "Malicious encryption of files to deny system access until a ransom is paid.",
    longDescription: 
        "Ransomware is a critical threat that targets the Availability of your data. It typically gains access through unpatched RDP ports or Phishing and moves laterally through the network using protocols like SMB.\n\n",
        threatlevel: "Threat Level: CRITICAL\n",
    osilayer: "OSI Layer: Layer 6 (Presentation) & Layer 7 (Application)\n",
        protocol: "Protocol: RDP, SMB, HTTP\n",
        vulnerability: "Vulnerability: Unpatched Software & Weak Backups\n\n"
        "Once executed, it uses high-level encryption to lock user files. The 'vulnerability' it exploits is often the lack of offline backups and unpatched Remote Desktop vulnerabilities, making the data recovery nearly impossible without the decryption key.",
    color: Colors.black, // Red for Critical Threat level
  ),
  ];

  @override
  Widget build(BuildContext context) {
    final carouselItems = carouselData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return GestureDetector(
        onTap: () {
          if (_currentIndex != index) return;
          Navigator.pushNamed(context, '/enemy_details', arguments: data);
        },
        child: Hero(
          tag: 'carousel_hero_${data.title}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: data.color,
                border: Border.all(color: Colors.white, width: 10.0), // Your 10px white border
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
                    fontSize: 20.0,
                    color: Colors.white,
                    fontFamily: AppFonts.main,
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: const MenuAppBar(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(AppImages.menuBackgroundAlt, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 280,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.4,
                      onPageChanged: (index, reason) => setState(() => _currentIndex = index),
                    ),
                    items: carouselItems,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          carouselData[_currentIndex].title,
                          style: const TextStyle(
                            fontSize: 32, 
                            color: Colors.white, 
                            fontFamily: AppFonts.main,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          carouselData[_currentIndex].details,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.white70, 
                            fontFamily: AppFonts.main,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}