Tango 単語帳アプリ

開発状況: MVP 計画中 · Flutter 3.32 · Riverpod 3 · Hive 4目的: 通勤 5 分でも集中 30 分でも学べる、Kindle ライクな単語リーダー & 学習アプリ

1. プロダクトビジョン

ポケットサイズの紙の単語帳をそのまま電子化し、IT 試験受験者が気軽に語彙を伸ばせるアプリ。

📖 単語帳モード – 横スワイプでページ送り、前回ページから自動再開

🎯 学習セッション – 語数スライダー / タイマートグルで開始 → 読む → クイズ → サマリー

📝 クイッククイズ – “弱点語キュー” などから即時出題

📊 履歴 & 一覧 – 進捗グラフと複合フィルタ検索

主要ターゲットは IT パスポート / 情報セキュリティマネジメント試験。シラバス差し替えで他資格にも対応可。

2. 画面構成とフロー

タブ

主目的

主な操作

📖 単語帳

スキマ学習

スワイプ・★しおり・ページカウンタ

🎯 学習

集中学習

スタートシート（語数 / 時間）→ 読む / クイズループ

📝 クイズ

速攻復習

出題元選択（全語 / 弱点 / ★）

📊 履歴 & 一覧

検索 & 統計

複合フィルタ + グラフ

3. 主なインタラクション

単語帳タブ

横スワイプで前後ページへ。

AppBar 右の 🔍 で BottomSheet 検索 → pageController.jumpToPage()。

サブタイトルに 現在 n / 全 N を常時表示（％不要）。

学習セッションタブ

スタートシートで「語数スライダー」または「タイマー (15/25/30 min)」を設定。

1 語ごとに 読む → 4 択クイズ のミニループ。

終了ダイアログに 学習時間 / 正答率 / 苦手語 を表示し、"苦手語をキューに追加" ボタン。

クイッククイズタブ

出題源ボタン：全語 / 弱点 / ★。

終了後「該当語を単語帳で確認」導線。

4. 技術スタック

Flutter 3.32 (Material 3)

状態管理: Riverpod 3 (hooks_riverpod)

ローカル DB: Hive 4 — word_box, progress_box, session_box, queue_box

コード生成: build_runner, freezed

グラフ: fl_chart 1.x

CI: GitHub Actions — ビルド +

5. データモデル（簡略版）

class Word { /* 略 */ }

class WordProgress {
  String wordId;
  int seen;
  int correct;
  int wrong;
  DateTime lastSeen;
  Set<String> tags; // weak / star / tag:network など
}

class Bookmark {
  int pageIndex;
  DateTime updated;
}

class SessionLog {
  /* 略 */
}

/// 苦手語キュー（FIFO 200 語上限）
class ReviewQueue {
  List<String> wordIds;
}

6. ディレクトリ構成

lib/
 ├─ main.dart
 ├─ ui/
 │   ├─ wordbook/
 │   ├─ study/
 │   ├─ quiz/
 │   └─ history/
 ├─ models/
 ├─ services/
 ├─ providers/
 └─ util/

7. 非機能・運用ポリシー & セキュリティ

項目

方針

オフライン

単語データ JSON を assets 同梱。差分更新は OTA API を検討。

アクセシビリティ

フォントサイズ変更・ダークモード・VoiceOver ラベル対応。

TTS

IT 用語読みをカスタム辞書で補正。

分析

Crashlytics はデフォルト ON、Analytics はユーザー opt‑in。

広告 (AdMob)

β版以降で導入。‑ google_mobile_ads を使用し、プライバシー設定画面で パーソナライズ広告 / 非パーソナライズ広告 を選択可能に。‑ GDPR/CCPA 対応: UMP SDK で同意ダイアログを表示。‑ COPPA 対象外アプリだが、13 歳未満は広告トラッキングを制限。

セキュリティ対策

‑ https 通信強制 (network_security_config)。‑ 依存パッケージを pubspec.lock 固定、Snyk で月 1 回脆弱性スキャン。‑ flutter_secure_storage でユーザー設定を暗号化保存。‑ 広告 ID は OS 標準 API で取得し、アプリ側では保持しない。

プライバシーポリシー

公開前に Web 上に掲示し、アプリ内の設定画面からリンク。

8. 開発環境セットアップ. 開発環境セットアップ

Flutter 3.32 SDK をインストール。

flutter pub get

dart run build_runner build --delete-conflicting-outputs

flutter run -d chrome もしくはシミュレータ。

lib/firebase_options.dart の "TODO" を Firebase コンソールで取得した
apiKey や appId など実際の値に置き換える。

9. コーディングガイドライン

flutter_lints 3 に準拠。

1 機能 = 1 PR。UI とロジックは分離。

hooks_riverpod で状態管理。Widget が 200 行超なら setState 禁止。

プロバイダ & サービス→ユニットテスト、UI

10. 開発フロー

ブランチ: feat/<チケット>

コミット: Conventional Commits type(scope): summary

PR 作成 → CI 必須。

レビュー後 squash & merge。

11. リリース手順

アドネットワークの AdUnit ID は `--dart-define` で渡す。

```bash
flutter run \
  --dart-define BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy \
  --dart-define INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxx/zzz

flutter build apk --release \
  --dart-define BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy \
  --dart-define INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxx/zzz
```
12. ロードマップ（MVP 〜 β版）

No

タイトル

ざっくり内容

Done の定義 (DoD)

1

WordbookScreen MVP

WordbookScreen を新規作成。PageView で WordDetailContent を横並びにし、SharedPreferences に pageIndex を保存／復帰。

* ビルド・テストが緑* アプリ再起動で最後のページから開始*

2

StudySessionController

学習セッション用 StateNotifier と StartSheet UI。語数スライダー／タイマートグル → 1 語読む → 4 択クイズ → 次へ。サマリー表示まで。

* 最低 10 語ループが動作* 目標語数／タイマー終了で自動終了* 正答率が計算される

3

QuickQuiz v2

ReviewQueue（弱点語 FIFO 200）を Hive Box として実装し、クイズ出題源（全語／弱点／★）ボタンを追加。

* キューが空ならボタンを無効化* クイズ終了で正答語はキューから削除* 単体テストで ReviewQueue ロジック検証

4 ✅

HistoryScreen

SessionLog を集計し、fl_chart で「日別学習時間折れ線」と「カレンダーヒートマップ」を表示。フィルタで日付範囲を切替可能。

* 折れ線グラフが日付軸で描画* ヒートマップが当月分を塗り分け*
5

ダークモード & カラー設計

Material 3 ColorScheme を ThemeExtension に切り出し、ThemeMode.system を初期値に。主要コンポーネントのコントラスト確認。

* ダーク／ライトで UI 崩れ無し*

6

Crashlytics / Analytics

firebase_crashlytics, firebase_analytics を導入。Analytics は設定画面のトグルで opt‑in。

* クラッシュ送信を手動確認* トグル変更で consent フラグが Hive に保存

備考: 各タスクは feat/<task-name> ブランチ → PR → CI 通過 → squash & merge のフローで進行。

## 12. ロードマップ（MVP 〜 β版）
 | No | タイトル                            | ざっくり内容                           | DoD                                |
 |----|------------------------------------|----------------------------------------|------------------------------------|
 | 1  | WordbookScreen MVP                 | …                                      | …                                  |
 | 2  | StudySessionController             | …                                      | …                                  |
 | 3  | QuickQuiz v2                       | …                                      | …                                  |
 | 4  | HistoryScreen                      | …                                      | …                                  |
 | 5  | ダークモード & カラー設計         | …                                      | …                                  |
 | 6  | Crashlytics / Analytics            | 後回し | リリース直前フェーズで導入 |
+| 8  | Interstitial 表示タイミング修正     | 学習終了後の広告表示をダイアログ閉   | 該当ロジックを修正し UX を確認     |
+| 9  | 広告パーソナライズ即時反映         | トグル後にバナーを再ロード           | プロバイダで再取得できる            |
+| 10 | ConsentForm 表示条件強化           | EU/EEA 判定後のみ同意ダイアログ表示   | isConsentFormAvailable チェック    |
+| 11 | iOS 権限設定追加                   | Info.plist に NSUserTracking… & SKAd  | iOS ビルド警告なし                   |
+| 12 | AdUnit ID の環境変数化             | --dart-define/Secrets で管理         | Secrets 経由でビルド動作OK          |
+| 13 | Flutter バージョン整合             | README・CI を 3.32 に統一            | CI ログに Flutter 3.32.0 が出力     |
+| 14 | テスト安定化と微調整               | テストの pump/timing を調整          | 全テスト安定パス                    |





13. ライセンス. ライセンス

MIT © 2025 Izumoto Hayato


Crashlytics / Analytics はリリース直前フェーズで導入予定です。
