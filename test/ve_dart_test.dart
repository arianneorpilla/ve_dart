import 'package:flutter_test/flutter_test.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test the Ve parser output', () async {
    var tagger = new Mecab();
    await tagger.init("assets/ipadic", true);

    List<dynamic> parsed = tagger.parse('にわにわにわにわとりがいる。');
    List<TokenNode> tokens = parsed.map((n) => n as TokenNode).toList();

    Parse parse = Parse(tokens);
    print(parse.words());
  });
}
