import 'models/word.dart';
import 'models/word_deck.dart';

final Word _word1 = Word(
  id: 'SG001',
  term: '情報セキュリティの概念',
  reading: 'じょうほうせきゅりてぃのがいねん',
  description: '情報資産を守るための取り組み全般。',
  categoryLarge: '技術要素',
  categoryMedium: 'セキュリティ',
  categorySmall: '情報セキュリティ 情報セキュリティの目的と考え方',
  categoryItem: '情報セキュリティの目的と考え方',
  importance: 5,
  english: 'ー',
);

final Word _word2 = Word(
  id: 'SG002',
  term: '機密性',
  english: 'Confidentiality',
  reading: 'きみつせい',
  description: '情報を許可された者だけが利用できる状態に保つこと。',
  categoryLarge: '技術要素',
  categoryMedium: 'セキュリティ',
  categorySmall: '情報セキュリティ 情報セキュリティの目的と考え方',
  categoryItem: '情報セキュリティの目的と考え方',
  importance: 5,
);

final Word _word3 = Word(
  id: 'SG003',
  term: '完全性',
  english: 'Integrity',
  reading: 'かんぜんせい',
  description: '情報が改ざんされていない状態を保つこと。',
  categoryLarge: '技術要素',
  categoryMedium: 'セキュリティ',
  categorySmall: '情報セキュリティ 情報セキュリティの目的と考え方',
  categoryItem: '情報セキュリティの目的と考え方',
  importance: 5,
);

final List<WordDeck> yourDeckList = [
  WordDeck(title: 'セキュリティ入門', words: [_word1, _word2, _word3]),
  WordDeck(title: '機密性と完全性', words: [_word2, _word3]),
];
