# FRUITIVA

FRUITIVA is a Flutter learning app for fruit processing. It teaches how fresh fruit becomes a product you can shape, dry, wrap, and pack: fruit toffee, fruit bars, and traditional sweets.

The promise on every screen is **From Fresh Fruit to Delicious Products.**

## What you can do in the app

- **Home.** Start from *Turn Fruits into Value*, then open toffee, fruit bars, or traditional sweets. A short process strip shows the shared path: select and wash, peel and pulp, mix and cook, shape or dry, wrap and pack.
- **Recipes.** The toffee studio covers aonla, bael, guava, mango, banana, and papaya. Each recipe lists ingredients, numbered steps, and the process notes that matter on the bench.
- **Process Lab.** Compare banana and mango fruit bars, and follow the line from fresh fruit to a wrapped bar.
- **Sweets.** Read aonla laddu and burfi, papaya burfi, and carrot burfi. This kitchen opens from Home.
- **Saved.** Tap the heart on a recipe. It stays on the phone and comes back under Saved.

## Screens

![FRUITIVA home screen](blog/appphoto.png)

## Run it

Install [Flutter](https://docs.flutter.dev/get-started/install), then from this folder:

```bash
flutter pub get
flutter run
```

The Android application id is `com.example.fruitiva`, version `1.0.0+1`.

## How it was made

The phone screens were designed in [Google Stitch](https://stitch.withgoogle.com), then built into this Flutter app with [Google Antigravity](https://antigravity.google). A written walkthrough of the product is in [the blog](blog/building-fruitiva-with-stitch-and-antigravity.html).

Design notes for the screens live in `.stitch/SITE.md` and `.stitch/DESIGN.md`. The clickable web prototype is `site/public/index.html`. The Flutter app is `lib/main.dart`.

The Stitch connection uses a local API key in `.mcp.json`. That file stays on your machine and is not part of this repository. Copy `.mcp.json.example` if you want to connect Stitch yourself, and put your own key in the ignored file.
