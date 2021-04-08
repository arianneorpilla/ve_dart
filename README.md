# ve_dart

<p align="left">
  <img src="https://i.postimg.cc/YCVj78ny/image.png" alt="picture" height=200>
  <img src="https://i.postimg.cc/SNbxgJXH/image.png" alt="picture" height=200>
</p>

**A Dart implementation of Ve.** A linguistic framework that's easy to use. No degree required. 

* **Segments Japanese morphemes to words** via the <b><a href="https://pub.dev/packages/mecab_dart">mecab_dart</b></a> package
* Based on the <a href="https://github.com/Kimtaro/ve/tree/master/java">Java port</a> of <b><a href="https://github.com/shirakaba/">Jamie Birch</a></b>, original <a href="https://github.com/Kimtaro/ve">Ruby implementation</a> by <b><a href="https://github.com/Kimtaro/">Kim Ahlström</b></a>
* Used in <b><a href="https://github.com/lrorpilla/jidoujisho">jidoujisho</b></a> as a **text segmentation parser** for tap to select subtitle functionality

## 🚨 Dependencies
This package requires use of the <b><a href="https://pub.dev/packages/mecab_dart">mecab_dart</b></a> package, which in turn makes use of ipadic dictionary files.

1. **Add the following dependencies** in your `pubspec.yaml` file.

```yaml
dependencies:   
   mecab_dart: 0.1.2
   ve_dart: 0.1.0
```

2. **Copy the ipadic dictionary files** in `assets/ipadic` to your own `assets` folder.

3. **Append the following** to the `assets` section of your `pubspec.yaml` file 

```yaml
flutter:
  assets:
    - assets/ipadic/
```
When done, you're ready to use the example below.

## 📖 Example
```dart
mecabTagger = Mecab();
await mecabTagger.init("assets/ipadic", true);

List<dynamic> parsed = mecabTagger.parse("今未練なんかこれっぽっちも無い");
List<TokenNode> tokens = parsed.map((n) => n as TokenNode).toList();

Parse parse = Parse(tokens);
List<String> words = [];
for (var word in parse.words()) {
  words.add(word.toString());
}

print(words); // [今, 未練, なんか, これ, っぽっ, ち, も, 無い]
```
