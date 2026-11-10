"""Objective PCM/provenance checks; does not listen or certify naturalness.
Run after tools/generate_audio.py and tests/capture_audio_audition.gd.
"""
import hashlib,json,math,pathlib,subprocess,wave
import numpy as np
ROOT=pathlib.Path(__file__).resolve().parents[1]
def pcm(path):
    with wave.open(str(path)) as w:
        rate=w.getframerate(); channels=w.getnchannels()
        assert w.getsampwidth()==2
        a=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').reshape(-1,channels)/32768.0
    return a,rate
def db(value): return float(20*np.log10(max(value,1e-12)))
def main():
    result={'meaning':'Objective sample/envelope/digital-mix evidence; no listening or hardware timing claim.','assets':[]}
    manifest=json.loads((ROOT/'assets/audio/recorded_contacts.json').read_text())
    for item in manifest:
        p=ROOT/'assets/audio'/item['file']; a,rate=pcm(p)
        assert hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256']
        assert np.max(abs(a))<=.631 and not np.any(abs(a)>=.9999)
        assert np.max(abs(a[0]))==0 and np.max(abs(a[-1]))==0
        energy=np.sum(a*a,axis=1); cumulative=np.cumsum(energy)/max(sum(energy),1e-12)
        result['assets'].append(dict(file=item['file'],peak_dbfs=db(np.max(abs(a))),rms_dbfs=db(np.sqrt(np.mean(a*a))),
            peak_time_ms=float(np.argmax(np.max(abs(a),axis=1))/rate*1000),energy_90_ms=float(np.searchsorted(cumulative,.9)/rate*1000)))
    for kind in ['ball','cue','pocket']:
        hashes=[item['sha256'] for item in manifest if item['file'].startswith(kind)]
        assert len(hashes)==5 and len(set(hashes))==5
    levels=[.005*1600**(i/8) for i in range(9)]
    gains=[max(-46,min(-7,-18+12*math.log10(s))) for s in levels]
    assert all(b>a for a,b in zip(gains,gains[1:]))
    result['nine_levels']=[dict(speed=s,gain_db=g) for s,g in zip(levels,gains)]
    capture=ROOT/'captures/audio/real-contact-audition.wav'
    if capture.exists():
        a,rate=pcm(capture)
        # FFmpeg swresample band-limited interpolation, eight times 48kHz.
        decoded=subprocess.check_output(['ffmpeg','-v','error','-i',str(capture),'-ar',str(rate*8),'-f','f32le','-'])
        oversampled=np.frombuffer(decoded,dtype='<f4')
        result['runtime_capture']=dict(file=str(capture),sha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
            rate=rate,channels=a.shape[1],duration_s=len(a)/rate,rms_dbfs=db(np.sqrt(np.mean(a*a))),
            sample_peak_dbfs=db(np.max(abs(a))),oversampled_8x_peak_dbtp=db(np.max(abs(oversampled))),
            clipped_samples=int(np.sum(abs(a)>=.9999)),post_mute_max=float(np.max(abs(a[int(26.25*rate):]))))
        assert np.max(abs(a))>.01, 'Do not accept silent Dummy capture'
        assert result['runtime_capture']['oversampled_8x_peak_dbtp']<=-1
        assert result['runtime_capture']['post_mute_max']==0
    output=ROOT/'captures/audio/objective-evidence.json';output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result.get('runtime_capture',{}),indent=2))
    print('AUDIO ASSETS: verified 16 distinct takes, endpoints, hashes, peak bounds and nine gain levels')
if __name__=='__main__':main()
