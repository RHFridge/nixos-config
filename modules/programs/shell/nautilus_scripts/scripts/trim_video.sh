#!/usr/bin/env bash
alacritty -e bash -c '
INPUT_FILE="$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)"
if [ ! -f "$INPUT_FILE" ]; then
    echo "No valid file selected."
    read -p "Press Enter to exit..."
    exit 1
fi
echo "Selected file:"
echo "$INPUT_FILE"
echo
read -p "Seconds to cut from START: " START_CUT
read -p "Seconds to cut from END: " END_CUT
read -p "Output filename (no extension): " USERNAME
OUTPUT_FILE="$(dirname "$INPUT_FILE")/${USERNAME}.mp4"
DURATION=$(ffprobe -v error \
    -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 \
    "$INPUT_FILE")
DURATION=${DURATION%.*}
FINAL_DURATION=$((DURATION - START_CUT - END_CUT))
if [ "$FINAL_DURATION" -le 0 ]; then
    echo "Error: trim exceeds video duration."
    read -p "Press Enter to exit..."
    exit 1
fi
echo
echo "Encoding..."
echo "Start: $START_CUT"
echo "End: $END_CUT"
echo "Duration: $FINAL_DURATION"
echo "Output: $USERNAME.mp4"
echo
ffmpeg -y \
    -ss "$START_CUT" \
    -i "$INPUT_FILE" \
    -t "$FINAL_DURATION" \
    -c:v h264_nvenc \
    -preset p5 \
    -rc vbr \
    -cq 23 \
    -c:a copy \
    -movflags +faststart \
    "$OUTPUT_FILE"
echo
echo "Done:"
echo "$OUTPUT_FILE"
read -p "Press Enter to close..."
'
