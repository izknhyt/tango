# tango
# IT資格学習 単語帳アプリ

A new Flutter project.
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

## Getting Started

This project is a starting point for a Flutter application.
1. [Install Flutter](https://docs.flutter.dev/get-started/install).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

A few resources to get you started if this is your first Flutter project:
## Folder Structure

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- `lib/` : main Dart source files
- `assets/words.json` : term definitions
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` : platform targets

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
---
This project continues to evolve with planned features such as improved spaced repetition algorithms, related links per term, analytics integration, TTS and advertising options.