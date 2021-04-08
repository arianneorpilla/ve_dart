# ve_dart

```dart
"離さないって決めたから" => ["離さない", "って", "決めた", "から"]
"そぞろに鼻を利かせては" => ["そぞろに", "鼻", "を", "利かせて", "は"]
"無作為に伸びてる雑草も" => ["無", "作為に", "伸びてる", "雑草", "も"]
"守りたいって言ったのさ" => ["守りたい", "って", "言った", "の", "さ"]
"何が起きようと変わらないままで" => ["何", "が", "起きよ", "う", "と", "変わらない", "まま", "で"]
```

<b>A Dart implementation of <a href="https://github.com/Kimtaro/ve">Ve</a>.</b> A linguistic framework that's easy to use. No degree required. 

* **Segments Japanese morphemes to words** via the <b><a href="https://pub.dev/packages/mecab_dart">mecab_dart</b></a> package
* Based on the <a href="https://github.com/Kimtaro/ve/tree/master/java">Java port</a> of <b><a href="https://github.com/shirakaba/">Jamie Birch</a></b>, original <a href="https://github.com/Kimtaro/ve">Ruby implementation</a> by <b><a href="https://github.com/Kimtaro/">Kim Ahlström</b></a>
* Used in <b><a href="https://github.com/lrorpilla/jidoujisho">jidoujisho</b></a> as a **text segmentation parser** for tap to select subtitle functionality

## 🚨 Dependencies
This package requires use of the <b><a href="https://pub.dev/packages/mecab_dart">mecab_dart</b></a> package, which in turn makes use of ipadic dictionary files.

1. **Add the following dependencies** in your `pubspec.yaml` file.

```yaml
dependencies:   
   mecab_dart: 0.1.2
   ve_dart: 0.1.3
```

2. **Copy the ipadic dictionary files** in `assets/ipadic` to your own `assets` folder.

3. **Append the following** to the `assets` section of your `pubspec.yaml` file 

```yaml
flutter:
  assets:
    - assets/ipadic/
```

4. **Add the following imports** to your code.
```dart
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';
```

When done, you're ready to use the example below.

## 📖 Example
```dart
// Initialise a mecab_dart tagger.
mecabTagger = Mecab();
await mecabTagger.init("assets/ipadic", true);

// Make a List<TokenNode> that can be passed to the constructor of Parse.
List<dynamic> parsed = mecabTagger.parse("今未練なんかこれっぽっちも無い");
List<TokenNode> tokens = parsed.map((n) => n as TokenNode).toList();
Parse parse = Parse(tokens);

// Make the output list.
List<Word> words = parse.words();
List<String> output = [];
for (var word in words) {
  output.add(word.toString());
}

print(output); // ["今", "未練", "なんか", "これ", "っぽっ", "ち", "も", "無い"]
```
