import 'package:flutter/material.dart';
import 'package:faker/faker.dart' hide Color, Image;

class CarouselItemData {
  final Color? color;
  final String? imagePath;
  final String? videoPath;
  final String title;
  final String? subtitle;
  final String details;
  final String longDescription; // This is the field the error was looking for
  String? _extraDetails;
  final String threatlevel;
  final String osilayer;
  final String protocol;
  final String vulnerability;

  static const String assertMsg =
      "'CarouselItemData' must have at least a color, imagePath, or videoPath.";

  CarouselItemData({
    this.color,
    this.imagePath,
    this.videoPath,
    required this.title,
    this.subtitle,
    required this.details,
    required this.longDescription,
    required this.threatlevel,
    required this.osilayer,
    required this.protocol,
    required this.vulnerability,

    String? extraDetails,
  }) : _extraDetails = extraDetails,
       assert(
         color != null || imagePath != null || videoPath != null,
         assertMsg,
       );

  String get extraDetails {
    // If no extra details are provided, it generates 30 sentences of fake text
    _extraDetails ??= faker.lorem.sentences(30).join(" ");
    return _extraDetails!;
  }

  set extraDetails(String? value) => _extraDetails = value;

  // You can update this to include your new abundant information
  String getAllDetails() => "$details\n\n$longDescription\n\n$extraDetails";
}