# swarm-checkin-regulation-checker

Swarmのチェックイン規制を確認するツール

## 設定

### (前準備) トークンの取得

事前にDeveloperサイトからアプリケーションを作成し，API KeyとClient ID，Client Secretを取得する。
リダイレクトURLには適当なURLを設定しておく。
リダイレクトURLは必ずしもアクセス出来る必要はない。

その後，以下のURLのクエリのCLIENT_IDとREDIRECT_URIを自分の値に置き換え，アクセスする。

```text
https://foursquare.com/oauth2/authenticate?client_id=CLIENT_ID&response_type=code&redirect_uri=REDIRECT_URI
```

アクセスを許可すると，リダイレクト先にcodeクエリが付いてリダイレクトされるので，codeを取得する。

取得後，以下のURLのクエリを自分の物に書き換えてアクセスすると，アクセストークンが取得出来る。

```text
https://foursquare.com/oauth2/access_token?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&grant_type=authorization_code&redirect_uri=REDIRECT_URI&code=CODE
```

### .envにアクセストークンを書く

.envファイルにアクセストークンを設定する。

```env
OAUTH_TOKEN=YOUR_OAUTH_TOKEN
```


## License

MIT License
