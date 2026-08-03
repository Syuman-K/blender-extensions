# gk-blender-extensions

自作 Blender アドオン(EvenMesh / PhasePorter / SculptBase / HollowKit / AutoSupportGen / PartSplit)の
**拡張リポジトリ**です。Blender の Get Extensions に登録すると、**Update ボタンだけで更新**できます。

## Blender への登録(1回だけ)

1. `Edit > Preferences > Get Extensions > Repositories`(右上の ∨ メニュー)→ `+` → **Add Remote Repository**
2. URL に以下を入力:
   ```
   https://raw.githubusercontent.com/Syuman-K/gk-blender-extensions/main/index.json
   ```
3. **Check for Updates on Startup** を有効にすると起動時に新版を確認します。
4. 既にZIPから入れていたアドオンは一度アンインストールし、このリポジトリの一覧から入れ直してください
   (Update ボタンは「そのリポジトリから入れた拡張」にだけ出ます)。

## 更新の公開(開発側)

各アドオンのリポジトリで `build.ps1`(バージョン上げ + テスト + dist ZIP)を済ませてから:

```
powershell -ExecutionPolicy Bypass -File .\publish.ps1
```

最新 `dist/<id>-<version>.zip` の収集 → `blender --command extension server-generate` で
`index.json` 再生成 → commit & push まで自動で行います。`-NoPush` で生成のみ。

Blender 側は Repositories の Sync(またはBlender再起動)で Update ボタンに反映されます。

---

> **2026-08-03: リポジトリ名を `blender-extensions` から `gk-blender-extensions` に変更しました。**
> 旧URLで登録済みの場合は、Blender の `Get Extensions > Repositories` で該当リポジトリの URL を
> 上記の新URLに書き換えてください(旧URLも当面は解決しますが、旧名で別リポジトリが作られると壊れます)。
