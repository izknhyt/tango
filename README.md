# IT資格学習 単語帳アプリ

日本の **情報セキュリティマネジメント試験（SG）** と  
**ITパスポート試験（IP）** の合格をサポートする **オフライン対応** 単語帳アプリです。  
Flutter（stable 3.32）で開発しており、Android / iOS / Web / デスクトップで動作します。

---

## 特長

| 分類 | 概要 |
|------|------|
| **完全オフライン** | 約 **860 語** を `assets/words.json` に同梱。通信不要で学習可 |
| **多彩な出題モード** | − ランダム / お気に入り / 間違えた語のみ<br>− 多肢選択クイズ・フラッシュカード式を切替 |
| **学習履歴** | Hive に閲覧履歴・クイズ結果を保存し、**日/週/月ごとの推移を fl_chart で可視化** |
| **お気に入り 3 色** | 赤★・黄★・青★ の AND / OR 組み合わせフィルタに対応 |
| **レスポンシブ UI** | iPhone SE 〜 iPad / Web まで 1 ソースで最適化（AppBar のアイコン自動集約、Chip 横スクロール等） |
| **設定** | ダークモード、フォントサイズ調整を `shared_preferences` で永続化 |
| **マルチプラットフォーム** | `flutter build web --base-href /tango/` で GitHub Pages にデプロイしブラウザデバッグ中 |

---

## 画面構成

- **Home**  
  今日の学習数・クイズ結果をカード表示。履歴詳細へ 1 タップで遷移  
- **Word List**  
  五十音順／重要度順などで並べ替え、検索・フィルタをワンシートに統合  
- **Favorites**  
  ★色フィルタ (AND/OR) で単語を絞り込み  
- **History**  
  最近閲覧した語を時系列で表示  
- **Quiz**  
  出題対象・形式・問題数をカスタマイズ  
- **Settings / About**

---

## インストール手順

 Flutter 環境を整備
git clone https://github.com/<your-id>/tango.git
cd tango
flutter pub get            # 依存解決
flutter run                # 実機 or エミュレータで起動
Web（GitHub Pages）ビルド
flutter build web --base-href /tango/ --pwa-strategy=none
# gh-pages ブランチに ./build/web を push
ディレクトリ構成（抜粋）

lib/
├─ models/          # Word, LearningStat などドメインモデル
├─ services/        # ReviewService, WordRepository, LearningRepository
├─ ui/              # 画面ウィジェット
│   ├─ widgets/     # 再利用コンポーネント（ResponsiveActions など）
│   └─ tabs/        # Home, WordList, Favorites, History, Quiz
assets/
└─ words.json       # 語彙データ（UTF-8）
開発ロードマップ

フェーズ	取り組み内容	状態
v0.9	WordListQuery.apply() による検索・並べ替え統合	✅ 完了
v0.10	SortType ラベルの拡張メソッド化、重複コード除去	🔧 実装中
v0.11	詳細画面を単語 ID 駆動へ、go_router 化	🗓️ 計画
v1.0	スペースドリピティションアルゴリズム / TTS / 広告導入	📌 予定
デバッグ方針
変更後は GitHub Pages に即 push → 実機ブラウザで確認。
バグを避けるため 1 ファイル単位で Codex に上書きコードを生成 → Push → 動作確認 の反復を推奨。
コントリビューション

Issue を立てて課題を共有
feature/<topic> ブランチを作成
ファイル丸ごと置換 でコミット → PR
CI (flutter test / web build) が通ればマージ
広告（AdMob）導入予定

現行バージョンではネットワーク通信を行わず、広告 SDK も含みません。
今後 AdMob を追加する際は以下を実施します。

ネットワーク権限・プライバシーポリシー・ユーザー同意画面の追加
端末情報・ログの送信最小化と暗号化
収益化をオフにできる設定
ライセンス

MIT License — LICENSE ファイルを参照してください。
