#!/usr/bin/env python3
from pathlib import Path
import argparse, asyncio, shutil, subprocess

async def edge_tts(text, output, voice='en-US-JennyNeural', rate='-2%'):
    import edge_tts
    await edge_tts.Communicate(text=text, voice=voice, rate=rate).save(str(output))

def espeak(text, output, voice='en-us', speed=160):
    wav = output.with_suffix('.wav')
    subprocess.run(['espeak','-v',voice,'-s',str(speed),'-w',str(wav),text], check=True)
    subprocess.run(['ffmpeg','-y','-i',str(wav),'-codec:a','libmp3lame','-q:a','3',str(output)], check=True)
    wav.unlink(missing_ok=True)

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--text-file',type=Path,default=Path('assets/narration.txt'))
    ap.add_argument('--output',type=Path,default=Path('assets/demo-narration.mp3'))
    args=ap.parse_args(); text=args.text_file.read_text(encoding='utf-8').strip(); args.output.parent.mkdir(parents=True, exist_ok=True)
    try:
        asyncio.run(edge_tts(text,args.output)); print('Generated with Edge TTS')
    except Exception as e:
        print('Edge TTS unavailable, using eSpeak:', e); espeak(text,args.output)
if __name__=='__main__': main()
