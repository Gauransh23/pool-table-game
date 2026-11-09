"""Edit recorded pool contacts: --source-dir PATH (requires numpy and ffmpeg).
Original URLs/licences/raw SHA256: assets/audio/sources/*.json.
Raw previews stay outside the game; supply the verified archived bytes to rebuild.
"""
import argparse
import hashlib
import json
import pathlib
import subprocess
import wave
import numpy as np
ROOT = pathlib.Path(__file__).resolve().parents[1]
RATE = 44100
# Separate takes in creator-labelled classes. Rail has ONE real take.
TAKES = {
    'ball': (851087, [.04, 1.02, 2.04, 3.02, 4.02], .20),
    'cue': (851086, [.05, 1.55, 3.05, 4.59, 5.98], .23),
    'rail': (42364, [.38], .29),
    'pocket': (851090, [.15, 1.66, 3.17, 4.66, 6.13], .65),
}
def write_wav(path, samples):
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(1); out.setsampwidth(2); out.setframerate(RATE)
        out.writeframes(np.round(np.clip(samples, -1, 1)*32767).astype('<i2').tobytes())
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-dir', type=pathlib.Path, required=True)
    args = parser.parse_args()
    manifest = []
    for kind, (source, peaks, duration) in TAKES.items():
        raw_path = args.source_dir / f'{source}.mp3'
        metadata = json.loads((ROOT / f'assets/audio/sources/{source}.json').read_text())
        if hashlib.sha256(raw_path.read_bytes()).hexdigest() != metadata['sha256']:
            raise ValueError(f'Unverified source bytes for {source}')
        decoded = subprocess.check_output(['ffmpeg','-v','error','-i',str(raw_path),
            '-f','f32le','-ac','1','-ar',str(RATE),'-'])
        signal = np.frombuffer(decoded, dtype='<f4').astype(np.float64)
        for index, peak in enumerate(peaks):
            lo, hi = max(0,int((peak-.07)*RATE)), int((peak+.02)*RATE)
            window = abs(signal[lo:hi])
            onset = lo+int(np.flatnonzero(window >= max(window)*.025)[0])
            start = max(0,onset-int(.0003*RATE))
            clip = signal[start:start+int(duration*RATE)].copy()
            # DC removal, 0.2ms attack de-click, 25ms end fade. No oscillator,
            # pitch shift, compression or added reverb; keep recorded resonances.
            clip -= np.mean(clip)
            clip[:9] *= np.linspace(0,1,9)
            fade = int(.025*RATE); clip[-fade:] *= np.linspace(1,0,fade)
            # Match early-body RMS, with -4dBFS sample-peak ceiling.
            rms = np.sqrt(np.mean(clip[:int(.08*RATE)]**2))
            gain = min(.085/max(rms,1e-9), .63/max(abs(clip)))
            clip *= gain
            name = f'{kind}_{index+1:02d}.wav'
            path = ROOT / 'assets/audio' / name
            write_wav(path,clip)
            if index == 0: write_wav(ROOT / f'assets/audio/{kind}.wav',clip)
            manifest.append(dict(file=name,source=source,take_peak_s=peak,
                source_start_s=start/RATE,duration_s=len(clip)/RATE,gain=gain,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    (ROOT/'assets/audio/recorded_contacts.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'Edited {len(manifest)} real takes; rail has one take, not three.')
if __name__ == '__main__': main()
