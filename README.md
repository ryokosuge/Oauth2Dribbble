# Oauth2Dribbble

Swift1.2で**Dribbble**の**OAuth2.0**を試してみました。

記事は[Swift1.2でDribbbleのOAuthを試してみた - qiita](http://qiita.com/ryokosuge/items/2b946504710ff856ed34)に書きました。

事前に必要な値としてDribbbleでApplicationを登録してもらい

- Client ID
- Client Secret
- Callback URL

の3つが必要になります。

その値を`Oauth2Dribbble/ViewController.swift`の

```swift
private let DribbbleClientID = "xxxxxxxx"
private let DribbbleClientSecret = "xxxxxxxx"
private let DribbbleRedirectURI = "xxxxxxxx"
```

に各値を入力してください。

そうすれば起動して一通り動きが確認できると思います。
