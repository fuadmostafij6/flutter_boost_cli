#!/usr/bin/env dart
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("Usage: fluttercli c featureX [--p] | featureX json2dart '{\"key\": \"value\"}' [--p]");
    return;
  }

  final action = arguments[0]; // create or json2dart
  final featureName = arguments[1]; // featureX
  final isProvider = arguments.contains("--p"); // Check if provider flag exists
  final jsonString = arguments.length > 3 ? arguments[3] : null;
  // Create feature with provider file, model, and screen
  if(action == "c" && featureName =="extension"){
    final baseDir = Directory(featureName);
    if (baseDir.existsSync()) {
      print("❌ Error: extension already exists.");
      return;
    }
    baseDir.createSync();
    File("extension/extension.dart")
        .writeAsStringSync(generateExtensionClass());
    print("✅ generated extension.dart");
  }
  else if (action == "create" && isProvider) {
    createFeatureWithProviderFiles(featureName);
  }
  // JSON to Dart conversion
  else if (action == "create" && jsonString != null) {
    if (isProvider) {
      createFeatureWithProviderFiles(featureName);
    }
    else{}
    generateJsonModel(isProvider ? "$featureName/${featureName}_model" : ".", featureName, jsonString);
  } else {
    print("❌ Unknown command. Use: fluttercli create featureX [--provider] | featureX json2dart  '{\"key\": \"value\"}' [--provider]");
  }
}

/// **Creates the complete feature folder with provider, model, and screen files**
void createFeatureWithProviderFiles(String featureName) {
  final baseDir = Directory(featureName);
  if (baseDir.existsSync()) {
    print("❌ Error: Feature '$featureName' already exists.");
    return;
  }

  baseDir.createSync();

  // Create provider, model, and screen folders
  Directory("$featureName/${featureName}_provider").createSync(recursive: true);
  Directory("$featureName/${featureName}_model").createSync(recursive: true);
  Directory("$featureName/${featureName}_screen").createSync(recursive: true);
  Directory("$featureName/${featureName}_service").createSync(recursive: true);

  // Create provider file
  File("$featureName/${featureName}_provider/${featureName}_provider.dart")
      .writeAsStringSync(generateProviderClass(featureName));

  // Create screen file
  File("$featureName/${featureName}_screen/${featureName}_screen.dart")
      .writeAsStringSync(generateScreenClass(featureName));

  // Create model file
  File("$featureName/${featureName}_model/${featureName}_model.dart")
      .writeAsStringSync(generateModelClass(featureName));

  File("$featureName/${featureName}_service/${featureName}_service.dart")
      .writeAsStringSync(generateServiceClass(featureName));

  print("✅ Feature folder structure created with provider, model, and screen, service!");
}



/// **Generates a Dart Service Class**
String generateServiceClass(String featureName) {
  return """
import 'package:flutter/material.dart';

class ${featureName[0].toUpperCase()}${featureName.substring(1)}Service {
  Future<String> fetchDataFromApi() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Fetched data for $featureName';
  }
}
""";
}


String generateExtensionClass() {
  return """
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  // Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  // Get aspect ratio (width / height)
  double get screenRatio => MediaQuery.of(this).size.aspectRatio;

  // Get vertical spacing as a fraction of screen height
  double heightFraction(double fraction) => screenHeight * fraction;

  // Get horizontal spacing as a fraction of screen width
  double widthFraction(double fraction) => screenWidth * fraction;

  // Get padding
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  // Get view insets bottom (keyboard or system insets)
  double get viewInsetsBottom => MediaQuery.of(this).viewInsets.bottom;

  // Get orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  // Check if the device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  // Check if the device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  // Get safe area height (excluding top and bottom padding)
  double get safeAreaHeight => screenHeight - screenPadding.top - screenPadding.bottom;

  // Get safe area width (excluding left and right padding if needed)
  double get safeAreaWidth => screenWidth;

  TextScaler get textScaleFactor => MediaQuery.of(this).textScaler;
}
""";


}

/// **Generates JSON Model**
void generateJsonModel(String directory, String featureName, String jsonString) {
  try {
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final dartModel = generateDartModel(featureName, jsonMap);

    final fileName = "$directory/${featureName}_model.dart";
    final file = File(fileName);
    file.writeAsStringSync(dartModel);

    print("✅ Model generated: $fileName");
  } catch (e) {
    print("❌ Error parsing JSON: $e");
  }
}
/// **Generates a Dart Model class from the given JSON map**
String generateDartModel(String featureName, Map<String, dynamic> jsonMap) {
  final className = "${featureName[0].toUpperCase()}${featureName.substring(1)}";

  // Create a list of fields and corresponding types
  final fields = <String, String>{};
  jsonMap.forEach((key, value) {
    fields[key] = _getType(value);
  });

  // Generate the constructor parameters and fields
  final constructorParams = fields.entries
      .map((entry) => "${entry.value} ${entry.key}")
      .join(", ");
  final toJsonEntries = fields.entries
      .map((entry) => '"${entry.key}": ${entry.key}')
      .join(", ");
  final fromJsonEntries = fields.entries
      .map((entry) => '${entry.key}: json["${entry.key}"]')
      .join(", ");

  // Generate the Dart model class code
  return """
// To parse this JSON data, do
//
//     final $className = ${className.toLowerCase()}FromJson(jsonString);

import 'dart:convert';

$className ${className.toLowerCase()}FromJson(String str) => $className.fromJson(json.decode(str));

String ${className.toLowerCase()}ToJson($className data) => json.encode(data.toJson());

class $className {
  ${fields.entries.map((entry) => '${entry.value} ${entry.key};').join("\n  ")}

  $className({
    $constructorParams
  });

  factory $className.fromJson(Map<String, dynamic> json) => $className(
    $fromJsonEntries,
  );

  Map<String, dynamic> toJson() => {
    $toJsonEntries
  };
}
""";
}

String _getType(dynamic value) {
  if (value is int) return "int?";
  if (value is double) return "double?";
  if (value is bool) return "bool?";
  if (value is List) return "List<String>?"; // Assuming all lists are of type String
  return "String?";  // Default to nullable String
}



/// **Generates a Dart Provider Class**
String generateProviderClass(String featureName) {
  final className = "${featureName[0].toUpperCase()}${featureName.substring(1)}Provider";
  return """
import 'package:flutter/material.dart';

class $className with ChangeNotifier {
  String? _data = "Loading...";
  bool _isLoading = false;

  String? get data => _data;
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(Duration(seconds: 2));

    _data = "Fetched Data";
    _isLoading = false;
    notifyListeners();
  }
}
""";
}

/// **Generates a Dart Model from JSON**
String generateModelClass(String featureName) {
  return """
// To parse this JSON data, do
//
//     final $featureName = ${featureName.toLowerCase()}FromJson(jsonString);

import 'dart:convert';

$featureName ${featureName.toLowerCase()}FromJson(String str) => $featureName.fromJson(json.decode(str));

String ${featureName.toLowerCase()}ToJson($featureName data) => json.encode(data.toJson());

class $featureName {
  String? name;
  int? age;

  $featureName({
    this.name,
    this.age,
  });

  factory $featureName.fromJson(Map<String, dynamic> json) => $featureName(
    name: json["name"],
    age: json["age"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "age": age,
  };
}
""";
}

/// **Generates a Screen Class**
String generateScreenClass(String featureName) {
  return """
import 'package:flutter/material.dart';

class ${featureName[0].toUpperCase()}${featureName.substring(1)}Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$featureName Screen'),
      ),
      body: Center(
        child: Text('Welcome to the $featureName screen'),
      ),
    );
  }
}
""";
}






