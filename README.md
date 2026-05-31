# qodo のサービス構成が大きく変わったためこのツールは機能しなくなりました

# qodo-gen 常駐コンテナ

Node.js 24 系ランタイムと qodo CLI を含む最小構成の常駐開発コンテナです。このリポジトリは `docker compose` ひとつでセットアップできるようにしています。

## 環境
ホストOSはWindows

## 構成概要
- `docker-compose.yml` … `node-tools` サービス（コンテナ名: `qodo-gen`）を定義。`HOST_DIR` を `/work` にマウントし、`.env` を自動で読み込みます。
- `Dockerfile` … `node:24-slim` ベースに git / ca-certificates を追加し、`@qodo/command` をグローバルインストール。`ENTRYPOINT` のシェル経由で `/work/.env` も読み込まれます。
- `.env(.sample)` … `HOST_DIR` や `QODO_API_KEY` などをまとめて管理できます。

## クイックスタート

1. `.env.sample` を `.env` にコピーし、**最低限 `HOST_DIR` と `QODO_API_KEY`** を自分の環境に合わせて書き換えます。

   ```powershell
   cp .env.sample .env
   # 例
   # HOST_DIR=D:/src/Container/qodo-gen
   # QODO_API_KEY=xxxxxxxxxxxxxxxx
   ```

   > `.env` を作らない場合は、`docker compose` 実行前に環境変数 `HOST_DIR` や `QODO_API_KEY` を直接エクスポートしてください。

2. コンテナをビルドして起動します。ホストの `HOST_DIR` が `/work` にマウントされた状態で常駐化します。

   ```powershell
   cd D:\src\Container\qodo-gen
   docker compose up -d --build
   ```

3. 作業時はログインシェルに入ります。`ENTRYPOINT` が `/work/.env` を自動で読み込むため、`.env` の値がコンテナ内のシェル環境にも反映されます。

   ```powershell
   docker exec -it qodo-gen bash -l
   # 作業ディレクトリは /work （HOST_DIR がマウントされる場所）
   ```

## Windows での半自動セットアップ（`qodo_start.ps1`）
GUI 付きの PowerShell スクリプトを同梱しています。`.env` の `HOST_DIR` 更新からコンテナ再構築・ログインまでをワンストップで行います。

1. PowerShell を開き、本リポジトリ直下で `./qodo_start.ps1` を実行します。
2. フォームが表示されるので、`HOST_DIR` のテキストボックスにホスト上のパスを入力するか **Browse** ボタンで選択します（既存の `.env` があればその値がデフォルト表示されます）。
3. **OK** を押すと `.env` の `HOST_DIR` を更新し、`docker compose down` → `docker compose up -d --build` を自動実行したあと、そのまま `docker exec -it qodo-gen bash -l` でコンテナ内に入ります。キャンセルした場合は何も変更されません。

> Browse ダイアログで選択したパスは自動的に `/` 区切りへ変換されます。`QODO_API_KEY` など他の変数は必要に応じて `.env` を直接編集してください。

## 運用のヒント
- `HOST_DIR` には必要なディレクトリのみを指定し、不要な領域はマウントしないでください。
- 常駐中でも `docker compose exec qodo-gen <cmd>` でコマンドをワンショット実行できます。
- qodo CLI 以外のツールは必要に応じてコンテナ内で追加インストールしてください（非特権ユーザー `dev` でログインしています）。
