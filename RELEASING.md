# Releasing Droppy

## Prerequisites

- `generate_appcast` installed (`brew install sparkle` or from the Sparkle release)
- `xcrun notarytool` credentials configured
- GitHub CLI (`gh`) authenticated

## Steps

### 1. Build and archive

In Xcode, bump `CFBundleShortVersionString` and `CFBundleVersion`, then **Product → Archive**.

### 2. Notarize and export

In the Organizer, click **Distribute App → Direct Distribution**. Xcode will notarize and export a `Droppy.app`.

### 3. Staple the notarization ticket

```bash
xcrun stapler staple Droppy.app
```

### 4. Place the app in its version folder

```
versions/
  vX.X.X/
    Droppy.app   ← put it here
```

### 5. Run the release script

```bash
./release.sh vX.X.X
```

This will:
- Zip `Droppy.app` → `versions/vX.X.X/Droppy-vX.X.X.zip`
- Copy the zip to `versions/sparkle/` and regenerate the appcast
- Fix GitHub Releases download URLs in the appcast
- Copy the updated appcast to `docs/appcast.xml`
- Copy any generated delta files back to `versions/vX.X.X/`

### 6. Create the GitHub release

Upload the files listed by the script output:

```bash
gh release create vX.X.X versions/vX.X.X/Droppy-vX.X.X.zip versions/vX.X.X/*.delta
```

### 7. Deploy the appcast

```bash
git add docs/appcast.xml
git commit -m "Release vX.X.X"
git push
```

Sparkle checks `vicjohnson.dev/Droppy/appcast.xml` (served from `docs/` via GitHub Pages).
