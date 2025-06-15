<<<<<<< ours
# 📚 IT Vocabulary Flashcard App (Flutter)

情報セキュリティマネジメント試験 (SG) や IT パスポート試験 (IP) の合格を目指す学習者向け **単語帳アプリ** です。  
オフラインで高速動作し、覚えた単語の学習履歴を可視化してモチベーションを維持できる設計になっています。
=======
# IT資格学習 単語帳アプリ

This Flutter project provides an offline vocabulary learning tool aimed at the Japanese **Information Security Management Exam (SG)** and **IT Passport Exam (IP)**.

## Features

- **Built-in Vocabulary**: around 860 terms stored in `assets/words.json` so the app works fully offline.
- **Searchable Word List**: search by term or reading and sort by importance.
- **Word Details**
  - Category information and brief descriptions
  - Mark favorites with red, yellow and blue stars
  - Browsing history is automatically recorded
- **Favorites Tab**
  - Filter by star color (AND/OR mode)
  - Open word details from your favorites
- **History Tab**
  - Shows recently viewed words with timestamps
- **Home Tab**
  - Displays today’s learned words, quiz counts and accuracy
  - Quick access to learning history details and about screen
- **Learning History Detail**
  - Charts your daily, weekly or monthly learning progress and quiz accuracy using `fl_chart`
- **Quiz Mode**
  - Multiple-choice or flashcard style quizzes
  - Select questions from all words, favorites or previous mistakes
  - Choose question count and star filters
  - Quiz results are stored locally and shown after each session
- **Today’s Summary**
  - Review words learned and quiz performance for a specific date
- **Settings**
  - Toggle dark mode
  - Adjust font size using shared preferences
- **Local Storage with Hive** for favorites, history and quiz stats
- Runs on Android, iOS, web and desktop platforms
>>>>>>> theirs

---

<<<<<<< ours
## ✨ 主な機能

| カテゴリ | 機能 |
|----------|------|
| 学習      | - 単語カードを左右スワイプで次/前へ<br>- クイズモード（4 択）<br>- 単語検索 & フィルタ（履歴・お気に入り）|
| データ    | - **Hive** で履歴・お気に入り・クイズ統計を永続化<br>- **shared_preferences** でユーザー設定を保存 |
| UI/UX    | - ホーム画面に「今日の学習サマリ」を表示（正解数・間違い数・学習単語数）<br>- ダークモード対応 |
| 便利      | - オフライン動作（API 不要）<br>- iOS / Android 双方に対応 |

---

## 📝 要件定義（抜粋）

- **対象資格**：情報セキュリティマネジメント試験、
- **搭載単語**：あらかじめアプリ内に JSON で格納（約 1,000 語）  
- **読み上げ**：将来的な有料オプションとして検討  
- **多言語対応**：不要（日本語のみ）  

🔄 今後のロードマップ

 単語出題アルゴリズム改善（忘却曲線ベース）
 単語関連リンク表示（シラバス別・タグ別）
 Firebase Crashlytics / Analytics 連携
 読み上げ機能（flutter_tts）をサブスクリプションで解放
 google adsenseで広告収入
=======
1. [Install Flutter](https://docs.flutter.dev/get-started/install).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Folder Structure

- `lib/` : main Dart source files
- `assets/words.json` : term definitions
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` : platform targets

---
This project continues to evolve with planned features such as improved spaced repetition algorithms, related links per term, analytics integration, TTS and advertising options.
>>>>>>> theirs
