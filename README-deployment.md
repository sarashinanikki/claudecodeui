# Claude Code UI - Linux Deployment Guide

このガイドでは、Claude Code UIをLinuxサーバー上でsystemdサービスとして実行し、ngrokを使用して外部からアクセス可能にする方法を説明します。

## 前提条件

- Ubuntu/Debian/CentOS等のLinuxサーバー
- Node.js 18以上がインストール済み
- sudo権限
- ngrokアカウント（https://ngrok.com/）

## インストール手順

### 1. ngrokのインストール

```bash
# ngrokをダウンロード
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok

# または手動でダウンロード
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/
```

### 2. ngrok認証トークンの設定

1. https://dashboard.ngrok.com/ でアカウントを作成
2. 認証トークンを取得
3. 後でサービス設定に使用します

### 3. Claude Code UIのデプロイ

```bash
# プロジェクトファイルをサーバーにアップロード
scp -r /path/to/claudecodeui user@your-server:/tmp/

# サーバーにログイン
ssh user@your-server

# インストールスクリプトを実行
cd /tmp/claudecodeui
sudo bash install-service.sh
```

### 4. ngrok認証トークンの設定

```bash
# サービスファイルを編集
sudo nano /etc/systemd/system/claude-code-ui.service

# Environment=NGROK_AUTH_TOKEN= の行を以下のように変更
Environment=NGROK_AUTH_TOKEN=your_actual_token_here

# サービスを再読み込みして再起動
sudo systemctl daemon-reload
sudo systemctl restart claude-code-ui
```

## 使用方法

### サービスの管理

```bash
# サービス状態の確認
sudo systemctl status claude-code-ui

# サービスの開始
sudo systemctl start claude-code-ui

# サービスの停止
sudo systemctl stop claude-code-ui

# サービスの再起動
sudo systemctl restart claude-code-ui

# ログの確認
sudo journalctl -u claude-code-ui -f
```

### ngrokトンネルURLの確認

サービス開始後、ログでngrokのトンネルURLを確認できます：

```bash
sudo journalctl -u claude-code-ui -f | grep "https://.*ngrok.io"
```

## ローカルテスト

サービスとして登録する前に、ローカルでテストできます：

```bash
# ngrok認証トークンを設定
export NGROK_AUTH_TOKEN=your_token_here

# スクリプトを実行
./scripts/start-with-ngrok.sh
```

## セキュリティ考慮事項

- ngrokの無料プランでは、URLが毎回変更されます
- 本番環境では、ngrokの有料プランまたは独自のリバースプロキシの使用を検討してください
- サービスは非特権ユーザー（claude-ui）で実行されます
- 適切なファイアウォール設定を行ってください

## トラブルシューティング

### サービスが起動しない場合

```bash
# ログを確認
sudo journalctl -u claude-code-ui -n 50

# 手動でスクリプトを実行してエラーを確認
sudo -u claude-ui /opt/claude-code-ui/scripts/start-with-ngrok.sh
```

### ngrokエラーの場合

- 認証トークンが正しく設定されているか確認
- ngrokがインストールされているか確認
- ネットワーク接続を確認

## アンインストール

```bash
# サービスを停止・無効化
sudo systemctl stop claude-code-ui
sudo systemctl disable claude-code-ui

# サービスファイルを削除
sudo rm /etc/systemd/system/claude-code-ui.service

# インストールディレクトリを削除
sudo rm -rf /opt/claude-code-ui

# ユーザーを削除
sudo userdel claude-ui

# systemdを再読み込み
sudo systemctl daemon-reload
```