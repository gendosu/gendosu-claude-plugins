# awesome-statusline

Claude Code ステータスライン自動設定スキルプラグイン。

## 概要

awesome-statusline プラグインは、Claude Code のステータスライン表示を自動設定するスキルを提供します。ディレクトリ名、Git ブランチ、モデル名、トークン使用状況などの重要な情報を表示するように自動的に設定します。

## 機能

- ✅ **自動セットアップ**: 1コマンドでステータスライン設定が完了
- ✅ **既存設定の保護**: 既存の `settings.json` を保持しながらマージ
- ✅ **自動バックアップ**: 設定更新前にバックアップを作成
- ✅ **冪等性**: 複数回実行しても安全
- ✅ **豊富な表示**: ディレクトリ、Git ブランチ、モデル、トークン情報を表示

### 表示例

```
skillth (feature/setup-statusline) [Sonnet] | 📊 38.8K (In:37442 Out:0 Cache:0)
```

## インストール

### マーケットプレイスを追加

```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

### プラグインをインストール

```bash
/plugin install awesome-statusline@gendosu-claude-plugins
```

## 使用方法

Claude Code に以下のように指示するだけです：

```
ステータスラインを設定して
```

または

```
statuslineをセットアップ
```

スキルは自動的に以下を実行します：
1. 必要な依存関係（`jq`）の確認
2. 必要なディレクトリ（`~/.claude/`）の作成
3. `~/.claude/settings.json` への設定マージ
4. ステータスラインスクリプト `~/.claude/statusline.sh` の作成
5. 適切なファイル権限の設定

## 設定

インストール後、以下のファイルが作成/更新されます：

### `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### `~/.claude/statusline.sh`

以下の情報でステータスライン表示を生成するシェルスクリプト：
- ディレクトリ名（青色）
- Git ブランチ名（括弧内）
- モデル名（角括弧内）
- トークン統計（合計、入力、出力、キャッシュ）

## 前提条件

- **jq**: JSON処理に必要

### jq のインストール

**macOS:**
```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt-get install jq
```

**Fedora/RHEL:**
```bash
sudo dnf install jq
```

## トラブルシューティング

### jq が見つからない

前提条件セクションの手順に従って jq をインストールしてください。

### ステータスラインが表示されない

1. Claude Code を再起動してください
2. `~/.claude/settings.json` に `statusLine` セクションがあることを確認
3. `~/.claude/statusline.sh` が実行可能であることを確認:
   ```bash
   ls -l ~/.claude/statusline.sh
   # 表示: -rwxr-xr-x
   ```

### 権限エラー

ディレクトリの権限を確認：
```bash
ls -ld ~/.claude/
chmod 755 ~/.claude/
```

## プロジェクト構造

```
plugins/awesome-statusline/
├── .claude-plugin/
│   └── plugin.json           # プラグイン設定
├── skills/
│   └── setup-statusline/
│       ├── SKILL.md          # スキルメタデータ
│       ├── README.md         # スキルドキュメント
│       └── setup.sh          # セットアップスクリプト
├── README.md                 # 英語ドキュメント
├── README.ja.md              # このファイル（日本語）
└── LICENSE                   # MIT ライセンス
```

## ドキュメント

- [Setup Statusline スキルドキュメント](./skills/setup-statusline/README.md) - 詳細な使用方法

## ライセンス

MIT License - 詳細は [LICENSE](./LICENSE) を参照

## 作者

**Gendosu**

## リポジトリ

https://github.com/gendosu/gendosu-claude-plugins

## バージョン

0.1.0
