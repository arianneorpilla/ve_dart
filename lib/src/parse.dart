/// Copyright (c) 2021 Leo Rafael Orpilla
/// MIT License
///
/// A Dart implementation of Ve.
/// A linguistic framework that's easy to use.
/// No degree required.
///
/// Based on the Java port by Jamie Birch.

import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';

class Parse {
  static const String NO_DATA = "*";

  static const int POS1 = 0;
  static const int POS2 = 1;
  static const int POS3 = 2;
  static const int POS4 = 3;
  static const int CTYPE = 4;
  static const int CFORM = 5;
  static const int BASIC = 6;
  static const int READING = 7;
  static const int PRONUNCIATION = 8;

  List<TokenNode> tokenArray;

  Parse(List<TokenNode> tokenArray) {
    if (tokenArray.length == 0)
      throw new Exception("Cannot parse an empty array of tokens.");

    this.tokenArray = tokenArray;
  }

  List<String> getFeaturesToCheck(TokenNode node) {
    List<String> featuresToCheck = [];

    for (int i = POS1; i < POS4 + 1; i++) {
      featuresToCheck.add(node.features[i].toString());
    }
    return featuresToCheck;
  }

  List<Word> words() {
    List<Word> wordList = [];
    TokenNode current;
    TokenNode previous;
    TokenNode following;

    for (int i = 0; i < tokenArray.length - 1; i++) {
      int finalSlot = wordList.length - 1;
      current = tokenArray[i];
      Pos pos; // could make this TBD instead.
      Grammar grammar = Grammar.Unassigned;
      bool eatNext = false;
      bool eatLemma = true;
      bool attachToPrevious = false;
      bool alsoAttachToLemma = false;
      bool updatePos = false;

      List<String> currentPOSArray = getFeaturesToCheck(current);

      if (currentPOSArray.length == 0 || currentPOSArray[POS1] == NO_DATA)
        throw new Exception("No Pos data found for token.");

      switch (currentPOSArray[POS1]) {
        case MEISHI:
//                case MICHIGO:
          pos = Pos.Noun;
          if (currentPOSArray[POS2] == NO_DATA) break;
          switch (currentPOSArray[POS2]) {
            case KOYUUMEISHI:
              pos = Pos.ProperNoun;
              break;
            case DAIMEISHI:
              pos = Pos.Pronoun;
              break;
            case FUKUSHIKANOU:
            case SAHENSETSUZOKU:
            case KEIYOUDOUSHIGOKAN:
            case NAIKEIYOUSHIGOKAN:
              // Refers to line 213 of Ve.
              if (currentPOSArray[POS3] == NO_DATA) break;
              if (i == tokenArray.length - 1)
                break; // protects against array overshooting.
              following = tokenArray[i + 1];
              switch (following.features[CTYPE]) {
                case SAHEN_SURU:
                  pos = Pos.Verb;
                  eatNext = true;
                  break;
                case TOKUSHU_DA:
                  pos = Pos.Adjective;
                  if (getFeaturesToCheck(following)[POS2] == TAIGENSETSUZOKU) {
                    eatNext = true;
                    eatLemma = false;
                  }
                  break;
                case TOKUSHU_NAI:
                  pos = Pos.Adjective;
                  eatNext = true;
                  break;
                default:
                  if (getFeaturesToCheck(following)[POS2] == JOSHI &&
                      following.surface == NI) pos = Pos.Adverb;
                  break;
              }

              break;
            case HIJIRITSU:
            case TOKUSHU:
              // Refers to line 233 of Ve.
              if (currentPOSArray[POS3] == NO_DATA) break;
              if (i == tokenArray.length - 1)
                break; // protects against array overshooting.
              following = tokenArray[i + 1];

              switch (currentPOSArray[POS3]) {
                case FUKUSHIKANOU:
                  if (getFeaturesToCheck(following)[POS1] == JOSHI &&
                      following.surface == NI) {
                    pos = Pos.Adverb;
                    eatNext = false;
                  }
                  break;
                case JODOUSHIGOKAN:
                  if (following.features[CTYPE] == TOKUSHU_DA) {
                    pos = Pos.Verb;
                    grammar = Grammar.Auxiliary;
                    if (following.features[CFORM] == TAIGENSETSUZOKU)
                      eatNext = true;
                  } else if (getFeaturesToCheck(following)[POS1] == JOSHI &&
                      getFeaturesToCheck(following)[POS3] == FUKUSHIKA) {
                    pos = Pos.Adverb;
                    eatNext = true;
                  }
                  break;
                case KEIYOUDOUSHIGOKAN:
                  pos = Pos.Adjective;
                  if (following.features[CTYPE] == TOKUSHU_DA &&
                          following.features[CTYPE] == TAIGENSETSUZOKU ||
                      getFeaturesToCheck(following)[POS2] == RENTAIKA)
                    eatNext = true;
                  break;
                default:
                  break;
              }
              break;
            case KAZU:
              // TODO: "recurse and find following numbers and add to this word. Except non-numbers like 幾"
              // Refers to line 261.
              pos = Pos.Number;
              if (wordList.length > 0 &&
                  wordList[finalSlot].getPartOfSpeech() == Pos.Number) {
                attachToPrevious = true;
                alsoAttachToLemma = true;
              }
              break;
            case SETSUBI:
              // Refers to line 267.
              if (currentPOSArray[POS3] == JINMEI)
                pos = Pos.Suffix;
              else {
                if (currentPOSArray[POS3] == TOKUSHU &&
                    current.features[BASIC] == SA) {
                  updatePos = true;
                  pos = Pos.Noun;
                } else
                  alsoAttachToLemma = true;
                attachToPrevious = true;
              }
              break;
            case SETSUZOKUSHITEKI:
              pos = Pos.Conjunction;
              break;
            case DOUSHIHIJIRITSUTEKI:
              pos = Pos.Verb;
              grammar = Grammar.Nominal; // not using.
              break;
            default:
              // Keep Pos as Noun, as it currently is.
              break;
          }
          break;
        case SETTOUSHI:
          // TODO: "elaborate this when we have the "main part" feature for words?"
          pos = Pos.Prefix;
          break;
        case JODOUSHI:
          // Refers to line 290.
          pos = Pos.Postposition;
          const List<String> qualifyingList1 = [
            TOKUSHU_TA,
            TOKUSHU_NAI,
            TOKUSHU_TAI,
            TOKUSHU_MASU,
            TOKUSHU_NU
          ];
          if (previous == null ||
              !(getFeaturesToCheck(previous)[POS2] == KAKARIJOSHI) &&
                  qualifyingList1.contains(current.features[CTYPE]))
            attachToPrevious = true;
          else if (current.features[CTYPE] == FUHENKAGATA &&
              current.features[BASIC] == NN)
            attachToPrevious = true;
          else if (current.features[CTYPE] == TOKUSHU_DA ||
              current.features[CTYPE] == TOKUSHU_DESU &&
                  !(current.surface == NA)) pos = Pos.Verb;
          break;
        case DOUSHI:
          // Refers to line 299.
          pos = Pos.Verb;
          switch (currentPOSArray[POS2]) {
            case SETSUBI:
              attachToPrevious = true;
              break;
            case HIJIRITSU:
              if (current.features[CFORM] != MEIREI_I) attachToPrevious = true;
              break;
            default:
              break;
          }
          break;
        case KEIYOUSHI:
          pos = Pos.Adjective;
          break;
        case JOSHI:
          // Refers to line 309.
          pos = Pos.Postposition;
          const List<String> qualifyingList2 = [TE, DE, BA]; // added NI
          if (currentPOSArray[POS2] == SETSUZOKUJOSHI &&
                  qualifyingList2.contains(current.surface) ||
              current.surface == NI) attachToPrevious = true;
          break;
        case RENTAISHI:
          pos = Pos.Determiner;
          break;
        case SETSUZOKUSHI:
          pos = Pos.Conjunction;
          break;
        case FUKUSHI:
          pos = Pos.Adverb;
          break;
        case KIGOU:
          pos = Pos.Symbol;
          break;
        case FIRAA:
        case KANDOUSHI:
          pos = Pos.Interjection;
          break;
        case SONOTA:
          pos = Pos.Other;
          break;
        default:
          pos = Pos.TBD;
        // C'est une catastrophe
      }

      if (attachToPrevious && wordList.length > 0) {
        // these sometimes try to add to null readings.
        wordList[finalSlot].getTokens().add(current);
        wordList[finalSlot].appendToWord(current.surface);
        wordList[finalSlot].appendToReading(getFeatureSafely(current, READING));
        wordList[finalSlot]
            .appendToTranscription(getFeatureSafely(current, PRONUNCIATION));
        if (alsoAttachToLemma)
          wordList[finalSlot]
              .appendToLemma(current.features[BASIC]); // lemma == basic.
        if (updatePos) wordList[finalSlot].setPartOfSpeech(pos);
      } else {
        Word word = new Word(
            current.features[READING],
            getFeatureSafely(current, PRONUNCIATION),
            grammar,
            current.features[BASIC],
            pos,
            current.surface,
            current);
        if (eatNext) {
          if (i == tokenArray.length - 1)
            throw new Exception(
                "There's a path that allows array overshooting.");
          following = tokenArray[i + 1];
          word.getTokens().add(following);
          word.appendToWord(following.surface);
          word.appendToReading(following.features[READING]);
          word.appendToTranscription(
              getFeatureSafely(following, PRONUNCIATION));
          if (eatLemma) word.appendToLemma(following.features[BASIC]);
        }
        wordList.add(word);
      }
      previous = current;
    }

    return wordList;
  }

  String getFeatureSafely(TokenNode token, int feature) {
    if (feature > PRONUNCIATION)
      throw new Exception("Asked for a feature out of bounds.");
    return token.features.length >= feature + 1 ? token.features[feature] : "*";
  }

  // POS1
  static const String MEISHI = "名詞";
  static const String KOYUUMEISHI = "固有名詞";
  static const String DAIMEISHI = "代名詞";
  static const String JODOUSHI = "助動詞";
  static const String KAZU = "数";
  static const String JOSHI = "助詞";
  static const String SETTOUSHI = "接頭詞";
  static const String DOUSHI = "動詞";
  static const String KIGOU = "記号";
  static const String FIRAA = "フィラー";
  static const String SONOTA = "その他";
  static const String KANDOUSHI = "感動詞";
  static const String RENTAISHI = "連体詞";
  static const String SETSUZOKUSHI = "接続詞";
  static const String FUKUSHI = "副詞";
  static const String SETSUZOKUJOSHI = "接続助詞";
  static const String KEIYOUSHI = "形容詞";
  static const String MICHIGO = "未知語";

  // POS2_BLACKLIST and inflection types
  static const String HIJIRITSU = "非自立";
  static const String FUKUSHIKANOU = "副詞可能";
  static const String SAHENSETSUZOKU = "サ変接続";
  static const String KEIYOUDOUSHIGOKAN = "形容動詞語幹";
  static const String NAIKEIYOUSHIGOKAN = "ナイ形容詞語幹";
  static const String JODOUSHIGOKAN = "助動詞語幹";
  static const String FUKUSHIKA = "副詞化";
  static const String TAIGENSETSUZOKU = "体言接続";
  static const String RENTAIKA = "連体化";
  static const String TOKUSHU = "特殊";
  static const String SETSUBI = "接尾";
  static const String SETSUZOKUSHITEKI = "接続詞的";
  static const String DOUSHIHIJIRITSUTEKI = "動詞非自立的";
  static const String SAHEN_SURU = "サ変・スル";
  static const String TOKUSHU_TA = "特殊・タ";
  static const String TOKUSHU_NAI = "特殊・ナイ";
  static const String TOKUSHU_TAI = "特殊・タイ";
  static const String TOKUSHU_DESU = "特殊・デス";
  static const String TOKUSHU_DA = "特殊・ダ";
  static const String TOKUSHU_MASU = "特殊・マス";
  static const String TOKUSHU_NU = "特殊・ヌ";
  static const String FUHENKAGATA = "不変化型";
  static const String JINMEI = "人名";
  static const String MEIREI_I = "命令ｉ";
  static const String KAKARIJOSHI = "係助詞";
  static const String KAKUJOSHI = "格助詞";

  // etc
  static const String NA = "な";
  static const String NI = "に";
  static const String TE = "て";
  static const String DE = "で";
  static const String BA = "ば";
  static const String NN = "ん";
  static const String SA = "さ";
}
