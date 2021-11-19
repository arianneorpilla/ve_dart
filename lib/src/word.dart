/// Copyright (c) 2021 Leo Rafael Orpilla
/// MIT License
///
/// A Dart implementation of Ve.
/// A linguistic framework that's easy to use.
/// No degree required.
///
/// Based on the Java port by Jamie Birch.

import 'package:ve_dart/ve_dart.dart';
import 'package:mecab_dart/mecab_dart.dart';

class Word {
  String? reading;
  String? transcription;
  Grammar? grammar;
  //String readingScript;
  //String transcriptionScript;
  String? lemma;
  Pos? partOfSpeech;
  List<TokenNode> tokens = [];
  String? word;

  Word(
    String read,
    String pronunciation,
    Grammar grammar,
    // String readingScript,
    // String transcriptionScript,
    String basic,
    Pos partOfSpeech,
    String nodeStr,
    TokenNode token,
  ) {
    this.reading = read;
    this.transcription = pronunciation;
    this.grammar = grammar;
    //this.readingScript = readingScript;
    //this.transcriptionScript = transcriptionScript;
    this.lemma = basic;
    this.partOfSpeech = partOfSpeech;
    this.word = nodeStr;
    tokens.add(token);
  }

  void setPartOfSpeech(Pos partOfSpeech) {
    this.partOfSpeech = partOfSpeech;
  }

  String? getLemma() {
    return lemma;
  }

  Pos? getPartOfSpeech() {
    return partOfSpeech;
  }

  List<TokenNode> getTokens() {
    return tokens;
  }

  String? getWord() {
    return word;
  }

  void appendToWord(String suffix) {
    word = word ?? "_" + suffix;
  }

  void appendToReading(String suffix) {
    reading = reading ?? "_" + suffix;
  }

  void appendToTranscription(String suffix) {
    transcription = transcription ?? "_" + suffix;
  }

  void appendToLemma(String suffix) {
    lemma = lemma ?? "_" + suffix;
  }

  @override
  String toString() {
    return word ?? "";
  }
}
