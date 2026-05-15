#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh v0.0.5"
    exit 1
fi

REPO="vicjohnson/Droppy"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_DIR="$ROOT_DIR/versions/$VERSION"
SPARKLE_DIR="$ROOT_DIR/versions/sparkle"
DOCS_DIR="$ROOT_DIR/docs"
ZIP_NAME="Droppy-$VERSION.zip"

if [ ! -d "$VERSION_DIR/Droppy.app" ]; then
    echo "Error: $VERSION_DIR/Droppy.app not found"
    exit 1
fi

echo "Zipping Droppy.app..."
ditto -c -k --sequesterRsrc --keepParent "$VERSION_DIR/Droppy.app" "$VERSION_DIR/$ZIP_NAME"

echo "Copying zip to sparkle directory..."
cp "$VERSION_DIR/$ZIP_NAME" "$SPARKLE_DIR/$ZIP_NAME"

echo "Generating appcast..."
generate_appcast --download-url-prefix "https://github.com/$REPO/releases/download/" "$SPARKLE_DIR"

echo "Fixing download URLs..."
sed -i '' 's|download/Droppy-\([^"]*\)\.zip|download/\1/Droppy-\1.zip|g' "$SPARKLE_DIR/appcast.xml"
sed -i '' 's|download/Droppy\([0-9.]*\)-\([0-9.]*\)\.delta|download/v\1/Droppy\1-\2.delta|g' "$SPARKLE_DIR/appcast.xml"

echo "Copying appcast to docs..."
cp "$SPARKLE_DIR/appcast.xml" "$DOCS_DIR/appcast.xml"

echo "Copying deltas to version directory..."
find "$SPARKLE_DIR" -name "*.delta" -exec cp {} "$VERSION_DIR/" \;

echo ""
echo "Done. Upload these files to the $VERSION GitHub release:"
echo "  $VERSION_DIR/$ZIP_NAME"
for delta in "$VERSION_DIR"/*.delta; do
    [ -f "$delta" ] && echo "  $delta"
done
echo ""
echo "Then commit and push docs/appcast.xml to deploy the appcast."
