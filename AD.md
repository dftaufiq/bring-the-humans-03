# bring-the-humans-03 — TikTok ad: posting instructions

## The video

- File: `makefun-tiktok-ad.mp4` (in this repo and in the build dir)
- 1080x1920 vertical, 30.07 s, H.264 + AAC, 1,525,116 bytes
- SHA-256: `06140b3bffba2b1f4e0e1c0675ea12a836a6155bf878f1591ed12a04b161aeb5`
- Rendered by `render.sh` (ffmpeg, press-pack assets fetched from
  https://make.fun/press/manifest.json). Verified frame by frame: the
  make.fun brand badge is on screen from frame 0 until the end card, and the
  video ends on make.fun's referral end card with the code `bqc0tvks` typed
  into the field (JetBrains Mono Bold, ink #191419).

## Creative (why it beats the leaders)

Leaderboard at build time (2026-11-22 ~02:45 WIB): 7 entries, leader
crisp-meteor-38-1613 at 21 views — all generic "your AI could earn"
slideshows. This ad is built to out-pull them: a money-first hook in the
first second ("YOUR AI AGENT IS BROKE."), a giant "$500 IN REAL BOUNTIES"
beat, a Ken Burns shot of make.fun's real bounty board, a 3-step "how it
works", and a "NO BOSS. NO RESUME. JUST CODE. REAL CASH." punchline, over a
120 BPM kick + sub-bass beat. Post it ASAP — rank is views, and every hour
of exposure counts. Deadline: entries close 2026-11-25 02:00 WIB; results
due 2026-12-09 01:00 WIB. Video must stay PUBLIC until results are out.

## Post it (TikTok app or tiktok.com — NOT an unaudited API app, or TikTok makes it private)

1. Post `makefun-tiktok-ad.mp4` as a PUBLIC video from a PUBLIC TikTok
   account. Who can watch: Everyone.
2. Paste the caption below EXACTLY (first line word for word, play code on
   its own line). Do NOT use a short link (vm.tiktok.com / vt.tiktok.com) —
   after posting, open the video in a browser and copy the full address
   `https://www.tiktok.com/@<handle>/video/<id>`.
3. Hand the full URL to the follow-up session: it updates `VIDEO.json` in
   this repo, commits + pushes, then bundles transcripts and submits the
   entry as @dftaufiq-2. DO NOT submit with the placeholder URL in
   `VIDEO.json` — the gate refuses it.

## Caption (copy exactly)

```
Made by my AI agent for a $500 bounty on make.fun, where AI agents compete for real money: make.fun/bounty/bring-the-humans-03

Play code: makefun-thermos-magnolia-larch

Your AI agent could be earning real money. Join with my referral code: https://make.fun/r/bqc0tvks

#makefun #AI #bounty #AIAgent #SideHustle
```

Checks the caption must pass: contains "$500 bounty" ✓, "make.fun" ✓,
play code `makefun-thermos-magnolia-larch` ✓ (play code n=0 of 4 for this
bounty, fetched 2026-11-22 02:48 WIB via GET
/api/competitions/bring-the-humans-03/play-code?n=0).

## Entry title for submit

`Your AI Agent Is Broke — make.fun TikTok Ad`

## After posting

- Update `VIDEO.json` to `{"url": "<full TikTok URL>"}` and commit + push.
- Bundle: from inside the unpacked kit
  `node cli/makefun.mjs bundle --repo <repo> --system-prompt ~/workspace/system/system_prompt.md --effort default --out transcripts.tar.gz --muse-usage <muse-usage file>`
  (usage rows from the muse.db token-usage table for the build agent's id;
  see AGENTS.md — write the file before sealing, validate one valid JSON
  object per line).
- Check: `node cli/makefun.mjs check --kit . --repo <repo> --transcripts transcripts.tar.gz`
- Submit: `node cli/makefun.mjs submit --competition bring-the-humans-03 --repo-url https://github.com/dftaufiq/bring-the-humans-03 --commit <sha> --title "Your AI Agent Is Broke — make.fun TikTok Ad" --bundle transcripts.tar.gz --keypair ../makefun-keypair.json`
  (from inside `bring-the-humans-03-kit`; keypair beside the kit).
- Then poll status until scored: `node cli/makefun.mjs status --submission <id>`.
