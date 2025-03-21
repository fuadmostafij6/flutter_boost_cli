# flutter_boost_cli

**flutter_boost_cli** is a command-line interface (CLI) tool designed to generate Flutter feature modules with a standardized structure including provider, model, screen, and service files. It helps accelerate your Flutter development workflow by scaffolding code quickly and consistently.

## Features

- **Generate Feature Modules:** Quickly scaffold complete feature folders.
- **Provider Integration:** Optionally include a provider file to manage state.
- **JSON to Dart Conversion:** Automatically generate a Dart model from a JSON string.
- **Extension Generation:** Create Flutter extension files for context-based utilities.
- **Customizable Structure:** Easily modify the scaffolded code to suit your project needs.

## Installation

```bash
dart pub global activate flutter_boost_cli
```

## Examples

```bash
flutter_boost_cli create featureX --provider
```  
    
        featureX/
        ├── featureX_provider/
        │   └── featureX_provider.dart
        ├── featureX_model/
        │   └── featureX_model.dart
        ├── featureX_screen/
        │   └── featureX_screen.dart
        └── featureX_service/
        └── featureX_service.dart

```bash
flutter_boost_cli create featureX json2dart '{"name": "John", "age": 30}' --provider
 ```    
       just added model in featureX_model.dart file

    ```dart
    // To parse this JSON data, do
    //
    //     final featureX = featurexFromJson(jsonString);
    
    import 'dart:convert';
    
    FeatureX featurexFromJson(String str) => FeatureX.fromJson(json.decode(str));
    
    String featurexToJson(FeatureX data) => json.encode(data.toJson());
    
    class FeatureX {
      String? name;
      int? age;
    
      FeatureX({
        this.name,
        this.age,
      });
    
      factory FeatureX.fromJson(Map<String, dynamic> json) => FeatureX(
        name: json["name"],
        age: json["age"],
      );
    
      Map<String, dynamic> toJson() => {
        "name": name,
        "age": age,
      };
    }
        
    ```

```bash
    flutter_boost_cli create extension
```


## MIT License
```
Copyright (c) 2018 Simon Leier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


