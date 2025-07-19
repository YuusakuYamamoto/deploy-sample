# SDB Sample Application

フルスタックテストアプリケーション - フロントエンドからバックエンド、データベースまでの疎通確認を行うためのサンプルアプリケーション

## 🏗️ 技術スタック

- **フロントエンド**: Next.js (React App Router) + TypeScript + Tailwind CSS
- **バックエンド**: Nest.js (TypeScript) + Swagger
- **データベース**: PostgreSQL (Docker)
- **ORM**: Prisma
- **通信**: REST API

## 🚀 セットアップ方法

### 方法1: 自動セットアップ（推奨）

```bash
./setup.sh
```

### 方法2: 手動セットアップ

#### 1. データベース起動
```bash
docker-compose up -d
```

#### 2. バックエンドセットアップ
```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run start:dev
```

#### 3. フロントエンドセットアップ
```bash
cd frontend
npm install
npm run dev
```

## 📋 確認用URL

- **フロントエンド**: http://localhost:3000
- **バックエンドAPI**: http://localhost:3001
- **API文書 (Swagger)**: http://localhost:3001/api
- **データベース**: localhost:5432

## 💡 主な機能

### フロントエンド
- ユーザー管理UI（作成・表示・削除）
- バックエンドヘルスチェック表示
- リアルタイム疎通確認
- レスポンシブデザイン

### バックエンド
- REST API エンドポイント
- Swagger API文書
- CORS設定済み
- バリデーション機能

### データベース
- PostgreSQL with Docker
- User・Post テーブル
- Prisma ORM

## 🔧 開発用コマンド

### バックエンド
```bash
cd backend
npm run start:dev      # 開発サーバー起動
npx prisma db push     # スキーマをDBに反映
npx prisma db pull     # DBからスキーマを取得
npm run db:migrate     # マイグレーション実行
npm run db:studio      # Prisma Studio起動
npm run lint           # コードチェック
npm run test           # テスト実行
```

### フロントエンド
```bash
cd frontend
npm run dev            # 開発サーバー起動
npm run build          # プロダクションビルド
npm run lint           # コードチェック
```

## 🗄️ データベース構造

```sql
-- users テーブル
id        INTEGER PRIMARY KEY
email     VARCHAR UNIQUE
name      VARCHAR
createdAt TIMESTAMP
updatedAt TIMESTAMP

-- posts テーブル
id        INTEGER PRIMARY KEY
title     VARCHAR
content   TEXT
published BOOLEAN
authorId  INTEGER (users.id参照)
createdAt TIMESTAMP
updatedAt TIMESTAMP
```

## 🌐 API エンドポイント

### ヘルスチェック
- `GET /` - Hello World
- `GET /health` - ヘルスチェック

### ユーザー管理
- `GET /users` - ユーザー一覧取得
- `POST /users` - ユーザー作成
- `GET /users/:id` - ユーザー詳細取得
- `PATCH /users/:id` - ユーザー更新
- `DELETE /users/:id` - ユーザー削除

## 🛠️ 疎通確認手順

1. **データベース疎通確認**
   - Docker ComposeでPostgreSQL起動
   - バックエンドからデータベース接続確認

2. **バックエンド疎通確認**
   - http://localhost:3001/health にアクセス
   - API文書 http://localhost:3001/api で動作確認

3. **フロントエンド疎通確認**
   - http://localhost:3000 にアクセス
   - ヘルスチェック表示確認
   - ユーザー作成・表示・削除機能確認

## 🔍 データベースデータ確認方法

### 方法1: Prisma Studio（推奨）
```bash
cd backend
npm run db:studio
```
- ブラウザで http://localhost:5555 にアクセス
- GUIでテーブルのデータを確認・編集可能
- リアルタイムでデータの変更が反映される

### 方法2: Docker経由でPostgreSQL直接接続
```bash
# usersテーブルのデータを確認
docker-compose exec postgres psql -U postgres -d sdb_test -c "SELECT * FROM users;"

# postsテーブルのデータを確認
docker-compose exec postgres psql -U postgres -d sdb_test -c "SELECT * FROM posts;"

# テーブル構造を確認
docker-compose exec postgres psql -U postgres -d sdb_test -c "\d users"
```

### 方法3: API経由でデータ確認
```bash
# ユーザー一覧を取得
curl http://localhost:3001/users

# 特定のユーザーを取得
curl http://localhost:3001/users/1
```

## 🔒 環境変数

### バックエンド (.env)
```
DATABASE_URL="postgresql://postgres:password@localhost:5432/sdb_test"
```

### フロントエンド (.env.local)
```
NEXT_PUBLIC_API_URL=http://localhost:3001
```

## 📝 プロジェクト構造

```
sdb_sample/
├── backend/                # NestJS バックエンド
│   ├── src/
│   │   ├── app.module.ts
│   │   ├── main.ts
│   │   ├── prisma/         # Prisma設定
│   │   └── users/          # ユーザーモジュール
│   ├── prisma/
│   │   └── schema.prisma
│   └── package.json
├── frontend/               # Next.js フロントエンド
│   ├── src/
│   │   ├── app/           # App Router
│   │   └── components/    # UI コンポーネント
│   └── package.json
├── docker-compose.yml     # PostgreSQL設定
├── setup.sh              # 自動セットアップスクリプト
└── README.md
```

## 🐛 トラブルシューティング

### データベース接続エラー
- PostgreSQLコンテナが起動しているか確認: `docker ps`
- データベースURL設定確認: `.env`ファイル

### ポート競合エラー
- 使用ポート確認: 3000 (frontend), 3001 (backend), 5432 (database)
- 他のプロセスが使用していないか確認

### パッケージインストールエラー
- Node.jsバージョン確認: v18以上推奨
- npm cache クリア: `npm cache clean --force`