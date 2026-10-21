#!/usr/bin/env bash
set -euo pipefail

for file in *.flac; do
    [ -e "$file" ] || continue

    output="${file%.flac}.mp3"

    ffmpeg -hide_banner -loglevel error \
        -i "$file" \
        -map_metadata 0 \
        -vn \
        -c:a libmp3lame \
        -b:a 320k \
        -ar 48000 \
        -ac 2 \
        "$output"

    echo "Converted: $output"
done
