# GitHub Secrets Setup Guide

このドキュメントでは、GitHub ActionsでOCIにデプロイするために必要なSecretsの設定方法を説明します。

## 必要なGitHub Secrets

GitHub リポジトリの Settings > Secrets and variables > Actions で以下のSecretsを設定してください：

### OCI CLI認証情報

| Secret名 | 説明 | 取得方法 |
|---------|------|--------|
| `OCI_CLI_USER` | OCIユーザーのOCID | OCI Console > Identity > Users |
| `OCI_CLI_TENANCY` | テナンシーのOCID | OCI Console > Administration > Tenancy Details |
| `OCI_CLI_FINGERPRINT` | APIキーのフィンガープリント | APIキー作成時に生成される |
| `OCI_CLI_PRIVATE_KEY` | APIキーの秘密鍵 | APIキー作成時にダウンロードした.pemファイルの内容 |
| `OCI_CLI_REGION` | OCIリージョン | 例: `ap-tokyo-1` |
| `OCI_COMPARTMENT_ID` | コンパートメントのOCID | OCI Console > Identity > Compartments |

### OCI Container Registry認証情報

| Secret名 | 説明 | 取得方法 |
|---------|------|--------|
| `OCI_AUTH_TOKEN` | OCIR認証トークン | OCI Console > User Settings > Auth Tokens で生成 |
| `OCIR_NAMESPACE` | OCIRネームスペース | OCI Console > Developer Services > Container Registry |

### アプリケーション設定

| Secret名 | 説明 | 例 |
|---------|------|-----|
| `DATABASE_URL` | データベース接続文字列 | `postgresql://user:password@host:5432/database` |

## APIキーの作成手順

1. OCI Console > Identity > Users > 対象ユーザー
2. API Keys セクションで "Add API Key" をクリック
3. "Generate API Key Pair" を選択
4. 秘密鍵(.pem)をダウンロード
5. 公開鍵の内容をコピーして追加
6. 表示されるConfigration File Previewからフィンガープリントをコピー

## Auth Tokenの作成手順

1. OCI Console > User Settings > Auth Tokens
2. "Generate Token" をクリック
3. 説明を入力（例: "GitHub Actions OCIR Access"）
4. 生成されたトークンをコピー（再表示されないので注意）

## セキュリティのベストプラクティス

- APIキーには最小限の権限のみを付与
- Auth Tokenは定期的に更新
- 秘密鍵ファイルは安全に保管
- 不要になったAPIキーやトークンは削除

## 権限設定

OCIでGitHub Actionsに必要な権限を設定するため、以下のポリシーを作成してください：

```
Allow group GitHubActionsGroup to manage container-instances in compartment YourCompartment
Allow group GitHubActionsGroup to manage load-balancers in compartment YourCompartment
Allow group GitHubActionsGroup to manage virtual-network-family in compartment YourCompartment
Allow group GitHubActionsGroup to use repos in compartment YourCompartment
```