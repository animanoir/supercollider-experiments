s.boot;
s.quit;
s.meter;
s.volume.gui;
Server.freeAll();

(
~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
~pad1 = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav");
)

s.record;
s.stopRecording;

TempoClock.default.tempo = 140/60;
(
t = TempoClock.default;
t.schedAbs(t.nextTimeOnGrid(4), {
  ~bassPlayer = ~bass.play(t, quant: 0);
  t.sched(16, {
  ~topPlayer = ~top.play(t, quant: 0);
  nil;
  });
  t.sched(8, {
  ~subPlayer = ~sub.play(t, quant: 0);
  nil;
  });
  nil;
});
)

~bass.stop;
~sub.stop;
// SynthDefs:
(
SynthDef(\play, { |buf, amp = 1.0, pan = 0.0, atk = 0.001, rel = 0.12, curve = -4, startPos = 0, rate = 1.0|
    var sig = PlayBuf.ar(2, buf, rate: rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan) * amp);
}).add;
)

// osckick
(
SynthDef(\osckick, {|amp = 1.0, atk = 0.001, rel = 0.12|
  
})
)

(
~stepTop = 1/4;  
~burstTop = Plazy({
    var span   = [3,4,8].choose;         
    var window = span * ~stepTop; 
    var n      = rrand(span * 2, span * 5); 
    var ratio  = exprand(0.45, 0.85); 
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cellTop = Pwrand([Pseq([~stepTop], 1), ~burstTop], [0.8, 0.2], inf); 
~top = Pbind(
    \amp, Pwhite(0.8, 1.0, inf),
    \instrument, \play,
    \buf, ~pad1,
    \startPos, Pwhite(0, ~pad1.numFrames),
    \dur, ~cellTop,
    \rate, 1.0,
    \pan, Pwhite(-0.8, 0.8, inf),
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
).play;
)

(
~stepBass = 1/2;  
~burstBass = Plazy({
    var span   = [4, 8].choose;         
    var window = span * ~stepBass; 
    var n      = rrand(span * 2, span * 5); 
    var ratio  = exprand(0.45, 0.85); 
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cellBass = Pwrand([Pseq([~stepBass], 1), ~burstBass], [0.8, 0.2], inf); 
~bass = Pbind(
    \amp, Pwhite(0.5, 1.0, inf),
    \instrument, \play,
    \buf, ~pad1,
    \startPos, Pwhite(0, ~pad1.numFrames),
    \dur, ~cellBass,
    \rate, 0.5,
    \pan, Pwhite(-0.1, 0.1, inf),
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
);
)

(
~stepSub = 1/1;  
~burstSub = Plazy({
    var span   = [1, 2, 4, 8].choose;         
    var window = span * ~stepSub; 
    var n      = rrand(span * 2, span * 5); 
    var ratio  = exprand(0.45, 0.85); 
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cellSub = Pwrand([Pseq([~stepSub], 1), ~burstSub], [0.8, 0.2], inf); 
~sub = Pbind(
    \amp, Pwhite(0.5, 0.8, inf),
    \instrument, \play,
    \buf, ~pad1,
    \startPos, Pwhite(0, ~pad1.numFrames),
    \dur, ~cellSub,
    \rate, -0.5,
    \pan, 0,
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
);
)
