# AGENTS.md – 開発・貢献ガイド

## 1. プロジェクト概要
- **名称:** IT資格学習単語帳アプリ
- **プラットフォーム:** Flutter 3.32 / Dart 3.4
- **目的:** ITパスポート・情報セキュリティマネジメント試験の語彙をオフラインで学習するフラッシュカードアプリ。

## 2. ディレクトリマップ
| パス | 役割 |
|------|------|
| `lib/` | アプリ本体の Dart ソース |
| `lib/models/` | ドメインモデル (`word.dart`, `learning_stat.dart` など) |
| `lib/services/` | リポジトリ・データ取得ロジック |
| `lib/tabs_content/` | 各タブの UI コンテンツ |
| `lib/ads/` | AdMob など広告関連コード |
| `assets/` | 静的アセット (`words.json`, フォント) |
| `test/` | 単体テスト |
| `web/` | Web デプロイ用リソース |

## 3. セットアップ & 実行
```bash
# Flutter 3.32 をインストール
flutter doctor -v

# 依存取得
flutter pub get

# 実行 (接続端末を自動検出)
flutter run
```

## 4. テスト・静的解析
```bash
flutter analyze       # Lint チェック
flutter test          # 既存のユニットテスト実行
```

`dart format --set-exit-if-changed .` を CI で実行しているため、コミット前に整形してください。

## 5. コーディングスタイル
- インデントは **2 スペース**
- 行長は **100 桁** まで
- ファイル名は `snake_case.dart`
- 変数・関数は `camelCase`、型は `PascalCase`
- import は `dart` → `package` → 相対パス の順
- テストファイルは `_test.dart` で終える

## 6. CI / CD
- `.github/workflows/flutter-web-deploy.yml` で GitHub Pages へ Web ビルドを自動デプロイ
- `main` ブランチへの push で実行される
- ステップ: `flutter pub get` → `flutter build web --base-href /tango/ --pwa-strategy=none`

## 7. 依存管理
- `pubspec.yaml` と `pubspec.lock` は常に同時にコミット
- アップグレード前に `flutter pub outdated` で差分を確認
- AdMob などネイティブ依存を追加する場合は Web ビルドへの影響を必ず検証

## 8. プルリクエスト
1. `develop` ブランチを起点に作業
2. コミットメッセージは Conventional Commits (`feat:`, `fix:`, `docs:` など)
3. PR では **Why / What / How** を簡潔に記載し、UI 変更時はスクリーンショットを添付
4. チェックリスト例:
   - [ ] `flutter analyze` に成功
   - [ ] `flutter test` に成功
   - [ ] コードフォーマット済み
5. 関連 Issue があれば `Closes #番号` でリンク

## 9. AI アシスタント利用メモ
- ディレクトリ構造を尊重してファイル名を指定してください
- 新規追加コードは `dart format` を実行
- 小さな差分でテストも更新すること

---
最終更新: 2025-06-24
