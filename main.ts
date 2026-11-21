// bring-the-humans-03 entry (Node 22, standard library only).
//
// The entry is the video itself: an original 30-second vertical ad for
// make.fun, posted publicly on TikTok from a public account, its caption
// carrying the bounty's line and the entrant's play code. VIDEO.json at the
// repository root names the video's full TikTok address, and the house reads
// the video's views from TikTok and ranks entries by views. Nothing this
// program writes about the video is scored.
//
// This program is the entrypoint the grader runs. It does one thing: it
// reads VIDEO.json from the repository root, checks it is a JSON object with
// a string "url" field pointing at a TikTok video, and writes those exact
// bytes to the output directory, where the gate reads them. It uses no
// network, no wall clock and no files outside the repository, so its two
// runs write the same bytes.
//
// The ad itself was made in the agent sessions uploaded with this entry:
// the creative was decided there, the press-pack brand badge and referral
// end card were fetched from https://make.fun/press/manifest.json, and the
// video was rendered with ffmpeg by render.sh in this repository (run it to
// reproduce makefun-tiktok-ad.mp4). The ad shows make.fun's brand badge
// (mascot mark + wordmark) from its first frame and ends on make.fun's
// referral end card with the entrant's own referral code typed into its
// field, both from the press pack and used as they are.
//
// Run it the way the grader does:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

function fail(message: string): never {
  console.error(`bring-the-humans-03: ${message}`);
  process.exit(1);
}

const videoPath = join(BOT_DIR, 'VIDEO.json');
let raw: Buffer;
try {
  raw = readFileSync(videoPath);
} catch (err) {
  fail(`could not read ${videoPath}: ${(err as Error).message}`);
}

let parsed: unknown;
try {
  parsed = JSON.parse(raw.toString('utf8'));
} catch (err) {
  fail(`VIDEO.json is not valid JSON: ${(err as Error).message}`);
}

const url =
  typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed)
    ? (parsed as { url?: unknown }).url
    : undefined;
if (typeof url !== 'string' || !url.startsWith('https://www.tiktok.com/')) {
  fail('VIDEO.json must be a JSON object with a TikTok video "url" string');
}

mkdirSync(OUTPUT_DIR, { recursive: true });
try {
  writeFileSync(join(OUTPUT_DIR, 'VIDEO.json'), raw);
} catch (err) {
  fail(`could not write VIDEO.json to ${OUTPUT_DIR}: ${(err as Error).message}`);
}
console.log(`bring-the-humans-03: wrote VIDEO.json (${raw.length} bytes) to ${OUTPUT_DIR}`);
