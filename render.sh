#!/usr/bin/env bash
# Render the bring-the-humans-03 TikTok ad for make.fun (1080x1920, 30 s).
#
# Concept (decided in the build session, to beat the leaderboard leaders —
# all generic "your AI could earn" slideshows at 0-21 views): a fast,
# money-first hook. "YOUR AI AGENT IS BROKE." -> other agents are winning
# real money -> the make.fun bounty board -> 3 steps -> "NO BOSS. NO RESUME.
# JUST CODE. REAL CASH." -> CTA -> referral end card with Dias's code.
#
# Brand: every make.fun mark/wordmark/colour comes from the press pack
# (https://make.fun/press/manifest.json), used as-is. The brand badge
# (press/brand-badge/9x16/makefun-badge-9x16.png) is overlaid from frame 0
# until the end card. The referral end card (press/referral-card/9x16/
# makefun-card-9x16-transparent.webm) is laid over the last 2.5 s per the
# press pack's own ffmpeg recipe, with Dias's referral code typed into the
# field in JetBrains Mono Bold, ink #191419.
#
# Assets are fetched from the press pack here (sha256-checked where the
# manifest lists one) so a fresh clone renders the same file.
set -euo pipefail
cd "$(dirname "$0")"

A=assets
OUT=makefun-tiktok-ad.mp4
CODE="bqc0tvks"                 # Dias's make.fun referral code (@dftaufiq-2)
FONT="$A/DejaVuSans-Bold.ttf"   # headlines (system font, copied below if needed)
MONO="$A/JetBrainsMono-Bold.ttf"
MAGENTA="0xc41c83"
INK="0x191419"

# --- assets (press pack, fetched as-is) -------------------------------------
mkdir -p "$A"
[ -f "$A/badge-9x16.png" ] || curl -sSL --retry 2 -o "$A/badge-9x16.png" \
  "https://make.fun/press/brand-badge/9x16/makefun-badge-9x16.png"
[ -f "$A/card-9x16-transparent.webm" ] || curl -sSL --retry 2 -o "$A/card-9x16-transparent.webm" \
  "https://make.fun/press/referral-card/9x16/makefun-card-9x16-transparent.webm"
[ -f "$A/board-dark.png" ] || curl -sSL --retry 2 -o "$A/board-dark.png" \
  "https://make.fun/press/screenshots/board-dark.png"
[ -f "$A/lockup-on-dark-2400.png" ] || curl -sSL --retry 2 -o "$A/lockup-on-dark-2400.png" \
  "https://make.fun/press/lockup-on-dark-2400.png"
[ -f "$A/JetBrainsMono-Bold.ttf" ] || curl -sSL --retry 2 -o "$A/JetBrainsMono-Bold.ttf" \
  "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Bold.ttf"
[ -f "$A/DejaVuSans-Bold.ttf" ] || cp /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf "$A/DejaVuSans-Bold.ttf"

# sha256 of the card is in the press manifest (edition 2026-11-21)
echo "286b76c671fa3bf3b1580a7c71675d7b7e502f4fb374b56d30f1104044808cd1  $A/card-9x16-transparent.webm" | sha256sum -c -

# --- content clip: 30 s, 1080x1920, 30 fps ----------------------------------
# Scenes: S1 magenta hook 0-3 | S2 ink money counter 3-8 | S3 board shot 8-14
#         S4 magenta 3 steps 14-20 | S5 ink punchlines 20-25 | S6 CTA 25-27.5
#         (27.5-30 is a plain magenta hold the end card washes over)
ffmpeg -y -v error \
  -f lavfi -i "color=c=$MAGENTA:s=1080x1920:d=30:r=30" \
  -f lavfi -i "color=c=$INK:s=1080x1920:d=30:r=30" \
  -framerate 1 -loop 1 -t 1 -i "$A/board-dark.png" \
  -i "$A/lockup-on-dark-2400.png" \
  -i "$A/badge-9x16.png" \
  -filter_complex "\
[0:v]fps=30[mag]; \
[1:v]fps=30,split[ink1][ink2]; \
[2:v]scale=2880:1800,zoompan=z='1.0+0.12*on/180':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=180:s=1080x1920:fps=30,format=yuv420p[board]; \
[3:v]scale=760:-2[lockup]; \
[mag][ink1]overlay=enable='between(t,3,8)'[b1]; \
[b1][ink2]overlay=enable='between(t,20,25)'[b2]; \
[b2][board]overlay=enable='between(t,8,14)'[b3]; \
[b3][lockup]overlay=(W-w)/2:880:enable='between(t,25,27.5)'[b4]; \
[b4][4:v]overlay=enable='lt(t,27.5)'[base]; \
[base]drawtext=fontfile=$FONT:text='YOUR AI':fontsize=150:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=620:enable='between(t,0,3)'[t1]; \
[t1]drawtext=fontfile=$FONT:text='AGENT':fontsize=150:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=790:enable='between(t,0,3)'[t2]; \
[t2]drawtext=fontfile=$FONT:text='IS BROKE.':fontsize=150:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=1010:enable='between(t,0.9,3)'[t3]; \
[t3]drawtext=fontfile=$FONT:text='MEANWHILE, OTHER AGENTS':fontsize=58:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=560:enable='between(t,3,8)'[t4]; \
[t4]drawtext=fontfile=$FONT:text='\$500':fontsize=300:fontcolor=white:borderw=6:bordercolor=black:x=(w-text_w)/2:y=720:enable='between(t,3.5,8)'[t5]; \
[t5]drawtext=fontfile=$FONT:text='IN REAL BOUNTIES':fontsize=64:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=1150:enable='between(t,4.5,8)'[t6]; \
[t6]drawtext=fontfile=$FONT:text='THIS IS make.fun':fontsize=72:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.65:boxborderw=24:x=(w-text_w)/2:y=150:enable='between(t,8,14)'[t7]; \
[t7]drawtext=fontfile=$FONT:text='AI AGENTS COMPETE':fontsize=64:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.65:boxborderw=24:x=(w-text_w)/2:y=1560:enable='between(t,8,14)'[t8]; \
[t8]drawtext=fontfile=$FONT:text='FOR REAL MONEY':fontsize=64:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.65:boxborderw=24:x=(w-text_w)/2:y=1650:enable='between(t,8,14)'[t9]; \
[t9]drawtext=fontfile=$FONT:text='1. YOUR AGENT BUILDS':fontsize=74:fontcolor=white:borderw=3:bordercolor=black:x=90:y=600:enable='between(t,14,20)'[t10]; \
[t10]drawtext=fontfile=$FONT:text='2. YOU SUBMIT':fontsize=74:fontcolor=white:borderw=3:bordercolor=black:x=90:y=820:enable='between(t,15.5,20)'[t11]; \
[t11]drawtext=fontfile=$FONT:text='3. USDC HITS':fontsize=74:fontcolor=white:borderw=3:bordercolor=black:x=90:y=1040:enable='between(t,17,20)'[t12]; \
[t12]drawtext=fontfile=$FONT:text='YOUR WALLET':fontsize=74:fontcolor=white:borderw=3:bordercolor=black:x=90:y=1140:enable='between(t,17,20)'[t13]; \
[t13]drawtext=fontfile=$FONT:text='NO BOSS.':fontsize=120:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=560:enable='between(t,20,25)'[t14]; \
[t14]drawtext=fontfile=$FONT:text='NO RESUME.':fontsize=120:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=720:enable='between(t,21,25)'[t15]; \
[t15]drawtext=fontfile=$FONT:text='JUST CODE.':fontsize=120:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=950:enable='between(t,22,25)'[t16]; \
[t16]drawtext=fontfile=$FONT:text='REAL CASH.':fontsize=120:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=1110:enable='between(t,23,25)'[t17]; \
[t17]drawtext=fontfile=$FONT:text='ENTER YOUR AI AGENT':fontsize=72:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=560:enable='between(t,25,27.5)'[t18]; \
[t18]drawtext=fontfile=$FONT:text='IN A BOUNTY':fontsize=72:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=660:enable='between(t,25,27.5)'[v]" \
  -map '[v]' -an -c:v libx264 -pix_fmt yuv420p -crf 18 -r 30 clip.mp4

# --- beat: 4-on-the-floor kick + sub bass, 30 s ------------------------------
ffmpeg -y -v error -f lavfi -i "aevalsrc='0.5*sin(2*PI*55*t)*exp(-7*mod(t,0.5))':d=30" \
  -f lavfi -i "aevalsrc='0.25*sin(2*PI*110*t)*lt(mod(t,1),0.5)+0.25*sin(2*PI*82.41*t)*gte(mod(t,1),0.5)':d=30" \
  -filter_complex "[0:a][1:a]amix=inputs=2:normalize=0,volume=0.6,alimiter=limit=0.8[a]" -map '[a]' -c:a aac -b:a 128k beat.m4a

# --- end card: press pack recipe (card over last 2.5 s, code typed in) ------
W=1080; H=1920; CARD="$A/card-9x16-transparent.webm"; LEN=2.5; REST=1.433
CX=210; CY=1232; CW=5; CH=78; MID=1271; SIZE=62
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 clip.mp4)
T=$(awk "BEGIN{print $D-$LEN}")
ffmpeg -y -v error -i clip.mp4 -i beat.m4a -c:v libvpx-vp9 -i "$CARD" -filter_complex "\
[0:v]scale=$W:$H:force_original_aspect_ratio=increase,crop=$W:$H,setsar=1,fps=60,tpad=stop_mode=clone:stop_duration=0,format=yuva420p,split[clip][soft]; \
[soft]gblur=sigma=28,eq=saturation=0.35,fade=t=in:st=$T:d=0.8:alpha=1[soft]; \
[clip][soft]overlay[bg]; \
[2:v]format=yuva420p,setpts=PTS-STARTPTS+$T/TB[card]; \
[bg][card]overlay=eof_action=pass,drawbox=x=$CX-2:y=$CY-2:w=$CW+4:h=$CH+4:color=white:t=fill:enable='gte(t,$T+$REST)',drawtext=fontfile=$MONO:text=$CODE:fontsize=$SIZE:fontcolor=0x191419:x=$CX:y=$MID-(ascent-descent)/2:enable='gte(t,$T+$REST)'[v]" \
  -map '[v]' -map '1:a' -c:v libx264 -pix_fmt yuv420p -crf 18 -r 30 -c:a aac -b:a 128k -movflags +faststart "$OUT"

ffprobe -v error -show_entries format=duration,size -show_entries stream=width,height,codec_name,duration -of default=noprint_wrappers=1 "$OUT"
sha256sum "$OUT"
echo "RENDERED: $OUT"
