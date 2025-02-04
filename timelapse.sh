#!/bin/bash
HOST="192.168.40.113:5000"
CAMERA="HOffice"
START_DATE=$1
START=$(date -d $START_DATE +%s)
END=$(date -d "$START_DATE + 1 day" +%s)

# Timestamp Text options
PADDING=10 # Offset the visual timestamp by this many pixels from the edge of the video
FONT="Fira Code"
FONT_SIZE=20 # Font size of the timestamp
FONT_COLOR=white # Font color of the timestamp
FONT_ALPHA=0.5 # Opacity of the font color (0.0 - 1.0)

TIMELAPSE_DIR="timelapses"

# curl -X POST \
#   -H 'Content-Type: application/json' \
#   -d "{\"name\":\"HOffice_$START_DATE\"}" \
#   "$HOST/api/export/$CAMERA/start/$START/end/$END"

  # -d "{\"playback\":\"timelapse_25x\",\"name\":\"HOffice_timelapse_$START_DATE-2\"}" \


# Timelapse

# ffmpeg -i "HOffice_$START_DATE.mp4" -vf "drawtext=fontsize=30:fontcolor=white:text='%{pts\:gmtime\:$(date -d $START_DATE +%s)}':x=(w-text_w):y=(h-text_h)"


find $PWD/storage/recordings/$START_DATE/*/$CAMERA/* -type f > $START_DATE-$CAMERA.txt

for i in $(cat $START_DATE-$CAMERA.txt); do
  CLIP_DATE="$(cut -d '/' -f 7 <<< "$i")"
  CLIP_HOUR="$(cut -d '/' -f 8 <<< "$i")"
  CLIP_MINUTE="$(cut -d '/' -f 10 <<< "$i" | cut -d '.' -f 1)"
  CLIP_SECOND="$(cut -d '/' -f 10 <<< "$i" | cut -d '.' -f 2)"

  CLIP_UTC="${CLIP_DATE}T$CLIP_HOUR:$CLIP_MINUTE:${CLIP_SECOND}Z"
  CLIP_UNIX=$(date -d $CLIP_UTC +%s)
  CLIP_TIMESTAMP=$(date -d $CLIP_UTC "+%Y-%m-%d %H:%M:%S %z")
  CLIP_FILENAME=$(date -d "$CLIP_TIMESTAMP" +%Y-%m-%dT%H%M%S%z)

  mkdir -p "$PWD/$TIMELAPSE_DIR/$START_DATE"

  echo "running $i" $CLIP_FILENAME
  
  ffmpeg -i $i \
  -vf "drawtext=font=$FONT:fontsize=$FONT_SIZE:fontcolor=$FONT_COLOR:alpha=$FONT_ALPHA:text='%{pts\:localtime\:$CLIP_UNIX\:%Y-%m-%d\ %H\\\\\:%M\\\\\:%S\ %z}':x=(w-text_w-$PADDING):y=($PADDING),drawtext=font=$FONT:fontsize=$FONT_SIZE:fontcolor=$FONT_COLOR:alpha=$FONT_ALPHA:text='$CAMERA':x=($PADDING):y=($PADDING),setpts=PTS/60" \
  -r 60 "$PWD/$TIMELAPSE_DIR/$START_DATE/$CLIP_FILENAME.mp4"
done

find $PWD/$TIMELAPSE_DIR/$START_DATE/* -type f > $START_DATE-$CAMERA-timelapse.txt

sed -ie 's/^/file /' $START_DATE-$CAMERA-timelapse.txt

ffmpeg -f concat -safe 0 -i $START_DATE-$CAMERA-timelapse.txt -c copy "$PWD/$START_DATE-$CAMERA-timelapse.mp4"