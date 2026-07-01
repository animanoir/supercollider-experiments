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

~tuyateveniste = Buffer.read(s, ~soundDir +/+ "tuyateveniste.wav");





s.record;
s.stopRecording;

TempoClock.default.tempo = 120/60;
(
t = TempoClock.default;
t.schedAbs(t.nextTimeOnGrid(4), {
  ~bassPlayer = ~bass.play(t, quant: 0);
  t.sched(16, {
  ~topPlayer = ~top.play(t, quant: 0);
  nil;
  });

  t.sched(8, {
  ~clicksPlayer = ~clicks.play(t, quant: 0);
  nil;
  });

  nil;
});
)

~bass.stop;
~sub.stop;
// SynthDefs:

//clicks
(
SynthDef(\click, {|buf, amp = 1.0, pan = 0.0, atk = 0.001, rel = 0.12|
  var sig = PlayBuf.ar(2, buf, rate: 1.0);
  var env = EnvGen.kr(Env.perc(atk, rel), doneAction: Done.freeSelf);
  sig = sig * env;
  Out.ar(0, Balance2.ar(sig[0], sig[1], pan) * amp);
}).add;
)

(
SynthDef(\play, { |buf, amp = 1.0, pan = 0.0, atk = 0.001, rel = 0.12, curve = -4, startPos = 0, rate = 1.0|
    var sig = PlayBuf.ar(2, buf, rate: rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan) * amp);
}).add;
)

(
SynthDef(\tuyateveniste, {| buf, pan=0.0, amp = 1.0, atk = 0.01, rel = 0.1, startPos = 0, rate = 1.0 |
  var sig = PlayBuf.ar(2, buf, rate: rate, startPos: startPos);
  var env = EnvGen.kr(Env.perc(atk, rel, 1), doneAction: Done.freeSelf);
  sig = sig * env;
  Out.ar(0, Balance2.ar(sig[0], sig[1], pan) * amp;)
}).add;
)

// osckick
(
SynthDef(\osckick, {|
  out = 0,
  amp = 1.0,
  pan = 0.0,
  freq = 55,
  atk = 0.001,
  rel = 0.3,
  curve = -4
  |
  // pitch envelope
  var fenv = EnvGen.kr(Env([freq * 7, freq], [rel * 0.2], \exp));
  // amp Envelope 
  var aenv = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
  var sig = SinOsc.ar(fenv);
  //sig = (sig * 1.4).tanh;
  sig = sig * aenv * amp;
  Out.ar(out, Pan2.ar(sig, pan));
}).add;
).play

// pbinds:

//vox1 pbind:
(
~stepKick = 1/4;
~burstKick = Plazy({
    var span   = [3,4,8].choose;
    var window = span * ~stepKick;
    var n      = rrand(span * 2, span * 5);
    var ratio  = exprand(0.45, 0.85);
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cellKick = Pwrand([Pseq([~stepKick], 1), ~burstKick], [0.8, 0.2], inf);

Pdef(\vox1, Pbind(
    \instrument, \tuyateveniste,
    \dur, ~cellKick,
    \buf, ~tuyateveniste,
    //\startPos, Pwhite(0, ~tuyateveniste.numFrames),

    //\startPos, ~tuyateveniste.numFrames / 4,

    \startPos, Pfunc({
      //var slices = [1, 8, 16].choose;
    var slices = 8;
      var block = (TempoClock.default.beats / 2).floor;
      (block % slices) * (~tuyateveniste.numFrames / slices);
    }),
    \amp, Pwhite(0.1, 0.5),
    \freq, Pseq([55, 55, 41, 55], inf),
    \atk, 0.001,
    \rel, Pwhite(0.1, 0.8),
    \amp, Pwhite(0.8, 0.8),
    \pan, Pwhite(-1.0, 1.0)
)).quant_(1);   // swaps wait for the next 4-beat boundary
)

//vox2 pbind:
(
~stepKick = 1/4;
~burstKick = Plazy({
    var span   = [3,4,8].choose;
    var window = span * ~stepKick;
    var n      = rrand(span * 2, span * 5);
    var ratio  = exprand(0.45, 0.85);
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cellKick = Pwrand([Pseq([~stepKick], 1), ~burstKick], [0.8, 0.2], inf);

Pdef(\vox2, Pbind(
    \instrument, \tuyateveniste,
    \dur, ~cellKick,
    \buf, ~pad1,
    //\startPos, Pwhite(0, ~tuyateveniste.numFrames),

    //\startPos, ~tuyateveniste.numFrames / 4,

    \startPos, Pfunc({
      var slices = [1, 8, 16].choose;
      var block = (TempoClock.default.beats / 1).floor;
      (block % slices) * (~tuyateveniste.numFrames / slices);
    }),
    \amp, Pwhite(0.1, 0.5),
    \freq, Pseq([55, 55, 41, 55], inf),
    \atk, 0.001,
    \rel, Pwhite(0.1, 1.0),
    \amp, Pwhite(0.8, 0.9),
    \pan, Pwhite(-1.0, 1.0)
)).quant_(1);   // swaps wait for the next 4-beat boundary
)

(
Pdef(\vox1).play;   // start once
)


Pdef(\vox1).stop;   // stop when you want silence
Pdef(\vox2).stop; 

(
~stepTop = 1/4;

// A single step = one event, fresh random position each time
~oneTop = Pbind(
    \dur, Pseq([~stepTop], 1),
    \startPos, Pwhite(0, ~pad1.numFrames, inf)
);

// A burst = many accelerating events sharing ONE position
~burstTop = Plazy({
    var span   = [8, 12, 18].choose;
    var window = span * ~stepTop;
    var n      = rrand(span * 2, span * 5);
    var ratio  = exprand(0.45, 0.85);
    var durs   = Array.geom(n, 1, ratio);
    var pos    = rrand(0, ~pad1.numFrames);
    Pbind(
        \dur, Pseq(durs / durs.sum * window, 1),
        \startPos, pos
    );
});

~cellTop = Pwrand([~oneTop, ~burstTop], [0.8, 0.2], inf);

// The whole Pchain goes into the Pdef, sharing quant with your other Pdefs
Pdef(\mainPad, Pchain(
    Pbind(
        \instrument, \play,
        \buf, ~pad1,
        \amp, Pwhite(0.8, 1.0),   // fixed: amp shouldn't go negative
        \rate, 1.0,
        \pan, 0,
        \rel, Pkey(\dur) * Pwhite(0.1, 1.0)
    ),
    ~cellTop
)).quant_(4);
)

Pdef(\mainPad).play;

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
// snare
(
SynthDef(\snare, { |out = 0, amp = 0.5, pan = 0, atk = 0.001, rel = 0.2, curve = -4|
    var env, tone, noise, sig;
    env   = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
    tone  = SinOsc.ar(180) * 0.5;          // tonal body
    noise = HPF.ar(WhiteNoise.ar, 1500);   // bright snap, clap-like
    sig   = (tone + noise) * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));        // Pan2: mono source
}).add;
)
(
~stepSnare = 1/1;   // one beat per step

// Burst cell (same idea as your other layers, grid-normalized)
~burstSnare = Plazy({
    var span   = [2, 4].choose;
    var window = span * ~stepSnare;
    var n      = rrand(span * 2, span * 4);
    var ratio  = exprand(0.45, 0.85);
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});

// Reusable cells
~hitS  = Pseq([~stepSnare], 1);         // one audible hit
~restS = Pseq([Rest(~stepSnare)], 1);   // one silent beat

// Deterministic IDM phrase: hit, rest, hit, rest, burst -> loop
~cellSnare = Pseq([~hitS, ~restS, ~hitS, ~restS, ~burstSnare], inf);

Pdef(\snare, Pbind(
    \instrument, \snare,
    \dur, ~cellSnare,
    \amp, Pwhite(0.6, 0.9),
    \pan, Pwhite(-0.3, 0.3),
    \rel, Pkey(\dur) * 0.1
)).quant_(4);
)

/*
(
~click1 = Buffer.read(s, ~soundDir +/+ "click1.wav");
~click2 = Buffer.read(s, ~soundDir +/+ "click2.wav");
~click3 = Buffer.read(s, ~soundDir +/+ "click3.wav");
~click4 = Buffer.read(s, ~soundDir +/+ "click4.wav");
~click5 = Buffer.read(s, ~soundDir +/+ "click5.wav");
~click6 = Buffer.read(s, ~soundDir +/+ "click6.wav");
~click7 = Buffer.read(s, ~soundDir +/+ "click7.wav");
~click8 = Buffer.read(s, ~soundDir +/+ "click8.wav");
)
*/
/*
(
~clicksArray = [
~click1,
~click2,
~click3,
~click4,
~click5,
~click6,
~click7,
~click8
];
)
// clickbind
(
~clicks = Pbind(
 \instrument, \click,
 \buf, ~clicksArray.choose,
 \dur, 1/4,
 \amp, Pwhite(0.1, 0.5),
 \atk, Pwhite(0.001, 0.01),
 \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
).play;
)
*/
