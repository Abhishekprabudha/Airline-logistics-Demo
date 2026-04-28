#!/usr/bin/env python3
from pathlib import Path
import argparse, asyncio, subprocess

async def edge_tts(
    text,
    output,
    voice='en-GB-SoniaNeural',
    rate='-8%',
    pitch='-2Hz',
):
    import edge_tts
    await edge_tts.Communicate(
        text=text,
        voice=voice,
        rate=rate,
        pitch=pitch,
    ).save(str(output))

def espeak(text, output, voice='en-gb+f3', speed=145):
    wav = output.with_suffix('.wav')
    subprocess.run(['espeak','-v',voice,'-s',str(speed),'-w',str(wav),text], check=True)
    subprocess.run(['ffmpeg','-y','-i',str(wav),'-codec:a','libmp3lame','-q:a','3',str(output)], check=True)
    wav.unlink(missing_ok=True)

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--text-file',type=Path,default=Path('assets/narration.txt'))
    ap.add_argument('--output',type=Path,default=Path('assets/demo-narration.mp3'))
    ap.add_argument('--voice',default='en-GB-SoniaNeural')
    ap.add_argument('--rate',default='-8%')
    ap.add_argument('--pitch',default='-2Hz')
    ap.add_argument('--fallback-voice',default='en-gb+f3')
    ap.add_argument('--fallback-speed',type=int,default=145)
    args=ap.parse_args(); text=args.text_file.read_text(encoding='utf-8').strip(); args.output.parent.mkdir(parents=True, exist_ok=True)
    try:
        asyncio.run(
            edge_tts(
                text,
                args.output,
                voice=args.voice,
                rate=args.rate,
                pitch=args.pitch,
            )
        )
        print(f'Generated with Edge TTS voice={args.voice} rate={args.rate} pitch={args.pitch}')
    except Exception as e:
        print('Edge TTS unavailable, using eSpeak:', e)
        espeak(
            text,
            args.output,
            voice=args.fallback_voice,
            speed=args.fallback_speed,
        )
if __name__=='__main__': main()
