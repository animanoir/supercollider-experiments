s.boot;
s.plotTree;
s.freeAll;

t = TempoClock(130/60).permanent_(true);

NetAddr.langPort;

~toMax = NetAddr.new("127.0.0.1", 7374);

~toMax.sendMsg('/test', 'bang')


(
SynthDef(\bleepFm, {
  | atk = 0.01, 
    rel = 0.01, 
    amp = 1.0, 
    pan = 0.0, 
    freq = 440 |
  var sig, env, mod, modHz;
  modHz = XLine.kr(1, 150, 10);
  mod = SinOsc.ar(modHz, mul: 300);
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel), doneAction: 2);
  sig = SinOsc.ar(freq: freq + mod);
  sig = sig * env * amp;
  Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef(\bleep, {
  | atk = 0.01, rel = 0.01, amp = 1.0, pan = 0.0, freq = 440|
  var sig, env;
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel), doneAction: 2);
  sig = SinOsc.ar(freq: freq);
  sig = sig * env * amp;
  Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
Synth(\bleep, 
  [rel: rrand(0.01, 0.5), 
  freq: [440, 220, 110].choose,
  amp: rrand(0.5, 1.0)],
);
)

(
~bleepPattern1 = Pbind(
  \instrument, \bleep,
  \dur, Pdefn(\bleepPattern1Dur, 1/4),
  \rel, Pwhite(0.01, 0.2),
  \freq, Prand([440, 220, 110], inf),
  \pan, Pdefn(\bleepPattern1Pan, 0.0),
  \amp, Pwhite(0.5, 1.0),
  \finish, {
    var freq = ~freq;
    SystemClock.sched(s.latency ? 0, {
      ~toMax.sendMsg('/bang', 'bang', freq);
      nil
    });
  }
);
)


(
~bleepFmPattern1 = Pbind(
  \instrument, \bleepFm,
  \dur, Pdefn(\bleepPattern1Dur, 1/2),
  \rel, Pwhite(0.01, 0.2),
  \freq, Prand([440, 220, 110], inf),
  \pan, Pdefn(\bleepFmPattern1Pan, 0.0),
  \amp, Pwhite(0.5, 1.0),
  \finish, {
    var freq = ~freq;
    SystemClock.sched(s.latency ? 0, {
      ~toMax.sendMsg('/bang', 'bang', freq);
      nil
    });
  }
);
)

(
~bleepPattern1.play(t, quant: 1);
~bleepFmPattern1.play(t, quant: 1);
)

(
Pdefn(\bleepFmPattern1Pan, Pfunc({sin(thisThread.beats * 2pi / 4)})).quant(4);
Pdefn(\bleepPattern1Pan, Pwhite(-1.0, 1.0)).quant_(4);
)
Pdefn(\bleepFmPattern1Pan, 0.0).quant(4);
Pdefn(\bleepPatternFmDur, 1/1).quant_(4);
Pdefn(\bleepPattern1Dur, 1/2).quant_(4);
Pdefn(\bleepPattern1Dur, 1/4).quant_(4);
