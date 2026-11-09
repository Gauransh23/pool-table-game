import wave,random,math,struct,pathlib
root=pathlib.Path('assets/audio')
for name,duration,freq,decay,noise in [('ball',.13,1900,45,.55),('rail',.17,185,30,.38),('cue',.18,800,38,.55),('pocket',.32,105,15,.7)]:
 r=random.Random(32); rate=44100; samples=[]; last=0
 for i in range(int(rate*duration)):
  t=i/rate; n=r.uniform(-1,1); last=.75*last+.25*n
  value=(math.sin(2*math.pi*freq*t)*.35+last*noise*3)*math.exp(-decay*t)*min(1,t/.001)
  samples.append(struct.pack('<h',int(max(-1,min(1,value))*.7*32767)))
 with wave.open(str(root/(name+'.wav')),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(b''.join(samples))
