#!/usr/bin/env bash

USERNAME="bonnex11"
COLLECTION_ID="1445811"
TARGET_DIR="$HOME/Pictures/Wallpapers"

mkdir -p "$TARGET_DIR"
PAGE=1
LAST_PAGE=1

echo "Downloading to $TARGET_DIR..."

while [ "$PAGE" -le "$LAST_PAGE" ]; do
  # Fetch JSON response for the current page
  RESPONSE=$(curl -s "https://wallhaven.cc/api/v1/collections/$USERNAME/$COLLECTION_ID?page=$PAGE")
  
  # Extract the total number of pages on the first run
  if [ "$PAGE" -eq 1 ]; then
    LAST_PAGE=$(echo "$RESPONSE" | jq -r '.meta.last_page // 1')
    echo "Found $LAST_PAGE page(s) in collection."
  fi
  
  echo "Fetching page $PAGE..."
  
  # Parse the image URLs and download them
  echo "$RESPONSE" | jq -r '.data[].path' | while read -r url; do
    wget -nc -q --show-progress -P "$TARGET_DIR" "$url"
  done

  PAGE=$((PAGE + 1))
  sleep 1 # Be polite to the API to avoid rate limits
done

echo "Sync complete!"
