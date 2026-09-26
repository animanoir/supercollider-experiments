s.quit({"--- Sound server has been stopped.".postln});
s.serverRunning;
s.freeAll;
s.meter;
MIDIClient.init;
MIDIClient.sources;
MIDIClient.disposeClient;

s.record;
s.stopRecording;

// bus (canales de audio) creation:

(
s.waitForBoot({
  s.newBusAllocators;
  ~mixerBus  = Bus.audio(s, 8);
  ~delayBus  = Bus.audio(s, 2);
  ~reverbBus = Bus.audio(s, 2);

  s.plotTree;
  t = TempoClock(120/60).permanent_(true);
  // main sound directories:
  ~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
  // individual sample files:
  ~kik1    = Buffer.read(s, ~soundDir +/+ "kik1.wav");
  ~hat1    = Buffer.read(s, ~soundDir +/+ "hat.wav");
  ~pad1    = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav");
  ~pad2    = Buffer.read(s, ~soundDir +/+ "luz.wav");
  ~kik2    = Buffer.read(s, ~soundDir +/+ "kik2.wav");
  ~deepKik = Buffer.read(s, ~soundDir +/+ "deepkik1.wav");
  // Elizabeth samples:
  ~elig1 = Buffer.read(s, ~soundDir +/+ "eligem1.wav");
  ~elig2 = Buffer.read(s, ~soundDir +/+ "eligem2.wav");
  ~elig3 = Buffer.read(s, ~soundDir +/+ "eligem3.wav");
  ~elig4 = Buffer.read(s, ~soundDir +/+ "eligem4.wav");
  ~elig5 = Buffer.read(s, ~soundDir +/+ "eligem5.wav");
  ~elig6 = Buffer.read(s, ~soundDir +/+ "eligem6.wav");
  ~eliGemidos = [~elig1, ~elig2, ~elig3, ~elig4, ~elig5, ~elig6];
  ~pigPad1 = Buffer.read(s, ~soundDir +/+ "pad-gritty-melancholic1.wav");
  ~pigPad2 = Buffer.read(s, ~soundDir +/+ "pad-gritty-melancholic2.wav");
  ~pigPads = [~pigPad1, ~pigPad2];
  ~p1wav = Buffer.read(s, ~soundDir +/+ "pg1.wav");
  ~p2wav = Buffer.read(s, ~soundDir +/+ "pg2.wav");
  ~p3wav = Buffer.read(s, ~soundDir +/+ "pg3.wav");
  ~p4wav = Buffer.read(s, ~soundDir +/+ "pg4.wav");
  ~p5wav = Buffer.read(s, ~soundDir +/+ "pg5.wav");
  ~p6wav = Buffer.read(s, ~soundDir +/+ "pg6.wav");
  ~p7wav = Buffer.read(s, ~soundDir +/+ "pg7.wav");

  ~pWavs = [
    ~p1wav, ~p2wav, ~p3wav, ~p4wav, ~p5wav, ~p6wav, ~p7wav,
  ];
  ~pMono = Buffer.readChannel(s, ~soundDir +/+ "pg1.wav", channels: [0]);
 
  ~pad3 = Buffer.readChannel(s, ~soundDir +/+ "pigment-granular-pad2.wav");

  ~wavClick1 = Buffer.read(s, ~soundDir +/+ "click1.wav");
  ~wavClick2 = Buffer.read(s, ~soundDir +/+ "click2.wav");
  ~wavClick3 = Buffer.read(s, ~soundDir +/+ "click3.wav");
  ~wavClick4 = Buffer.read(s, ~soundDir +/+ "click4.wav");
  ~wavClick5 = Buffer.read(s, ~soundDir +/+ "click5.wav");
  ~wavClick6 = Buffer.read(s, ~soundDir +/+ "click6.wav");
  ~wavClick7 = Buffer.read(s, ~soundDir +/+ "click7.wav");
  ~wavClick8 = Buffer.read(s, ~soundDir +/+ "click8.wav");
  
 ~wavClicks = [
  ~wavClick1,
  ~wavClick2,
  ~wavClick3,
  ~wavClick4,
  ~wavClick5,
  ~wavClick6,
  ~wavClick7,
  ~wavClick8,
 ];
  // ---- SynthDefs -----------------------------------------------
  SynthDef(\wav1, { |buf, amp = 1.0, pan = 0.0, rate = 1.0, startPos = 0,
    atk = 0.01, rel = 0.01, cutoff = 1.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = sig * env * amp;
    // ExpRand for XLine start value: exponential start must be > 0
    sig = HPF.ar(sig, XLine.kr(ExpRand(20, 200), 20000, Rand(0.5, 1.0)), Rand(0.5, 1.0));
    sig = Limiter.ar(sig);
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;

  SynthDef(\simpleBuf, { |buf, pan = 0.0, atk = 0.0, rel = 1.0, rate = 1.0, amp = 1.0|
    var sig, env;
    env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, 1.0);
    sig = sig * env * amp;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;

  // kick from sample
  SynthDef(\sKik1, { |buf, amp = 1.0, rate = 1.0, pan = 0.0, atk = 0.0, rel = 1.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate);
    var lineTime = Rand(0.1, 1.0);
    var mod = SinOsc.kr(0.2, 3pi/2).exprange(0.01, 0.5);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = sig * env;
    sig = LPF.ar(sig, XLine.kr(Rand(0, 10000), 20000, lineTime), lineTime);
    sig = sig.round(mod) * amp;
    sig = Limiter.ar(sig);
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;

  // noise hat
  SynthDef(\noiseHat, { |amp = 0.5, rel = 1.0, cutoff = 1.0, pan = 0.0|
    var sig = WhiteNoise.ar(0.1);
    var lineTime = Rand(0.1, 1.0);
    var env = EnvGen.kr(Env.perc(0.01, rel, 1, 1), doneAction: 2);
    sig = sig * env * amp;
    sig = HPF.ar(sig, XLine.kr(Rand(0, 10000), 20000, lineTime), lineTime);
    sig = Limiter.ar(sig);
    Out.ar(0, Pan2.ar(sig, pan));
  }).add;

  s.sync;
  "--- Executed function inside s.waitForBoot;".postln;
});
)

(
SynthDef(\playBuf, {
  | buf = 0, out = 0, rate = 1.0, loop = 0|
  var env = EnvGen.kr(Env.linen(0.005, BufDur.kr(buf) - 0.01, 0.005), doneAction: 2);
  var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, loop: loop, doneAction: 2) * env;
  Out.ar(out, Balance2.ar(sig[0], sig[1], 0.0));
}).add;
)

(
~pbindPad3 = Pbind(
  \instrument, \playBuf,
  \dur, Pfunc{ ~pad3.duration * t.tempo },
  \buf, ~pad3
)
)

~seqPad3 = ~pbindPad3.play(t, quant: 4);

(
~pbindRhythmClicks = Pbind(
  \instrument, \simpleBuf,
  \dur, Pdefn(\rcDur, 1/4),
  \buf, Prand(~wavClicks, inf),
  \amp, Pdefn(\pbrcAmp, Prand([0.1, 1.0], inf)),
  \pan, Pdefn(\pbrcPan, 0.0)
);
)

(
var moanSelection = 0;
var selectedBuf = Pdup(4, Prand(~eliGemidos, inf));
~randomEliMoans = Pbind(
  \instrument, \simpleBuf,
  \dur, Pdefn(\remDur, 1/4),
  \moanSelector, 0,
  \rel, Pdefn(\remRel, Pwhite(0.1, 0.5)),
  \buf, Pswitch1(
    [selectedBuf, Prand(~eliGemidos, inf)],
    Pdefn(\moanSel, 0)
  ),
  \atk, Pdefn(\remAtk, Pwrand([0.0, 0.1], [0.8, 0.2], inf)),
  \pan, Pdefn(\remPan, Pwhite(-0.5, 0.5))
);
)

(
var selectedBuf = Pdup(8, Prand(~pigPads, inf));
var selectedBufInd = ~pad1;
~repeatingPads = Pbind(
  \instrument, \simpleBuf,
  \dur, Pdefn(\rpDur, 1/2), 
  \rel, Pdefn(\rpRel, Pwhite(0.5, 1.0)),
  \rate, Pdefn(\rpRate, 1.0),
  \buf, selectedBuf,
  \atk, Pdefn(\rpAtk, Pwrand([0.5, 0.1], [0.8, 0.2], inf)),
  \pan, Pwhite(-0.5, 0.5)
);
)

(
  ~pbindNoiseHat = Pbind(
    \instrument, \noiseHat,
    \amp, Pdefn(\noiseHat, Pwhite(0.1, 1.0)),
    \rel, Pwhite(0.01, 0.1),
    \dur, Pdefn(\nhDur, 1/8),
    \pan, Pwhite(-1.0, 1.0);
  );
)

(
~pbindKik1 = Pbind(
  \instrument, \sKik1,
  \dur, Pdefn(\kikDur, Pseq([1/2, 1/2, 1/4], inf)),
  \amp, Pdefn(\kikAmp, 1.0)
)
)



(
~pbindPad2 = Pbind(
  \instrument, \wav1,
  \buf, ~pad1,
  \dur, Pdefn(\pad2Dur, 1/2),
  \rel, Pwhite(0.2, 1.0),
  \amp, Pdefn(\pad2Amp, 1.0),
  \startPos, Pwhite(0, ~pad1.numFrames - 1, inf)
);
)

// main sequence:
~seqRepeatingPads = ~repeatingPads.play(t, quant: 4);
Pdefn(\rpRate, 2.0).quant(4);
Pdefn(\rpRate, 1.0).quant(4);
Pdefn(\rpAtk, 0.0);
~seqRepeatingPads.stop;

~seqPad2 = ~pbindPad2.play(t, quant: 4);
~seqPad2.stop;

Pdefn(\pad2Dur, Prand([1/2, Prand([1/4, 1/2], inf), inf]));

~seqRandomEliMoans = ~randomEliMoans.play(t, quant: 4);
~seqRandomEliMoans.stop;
Pdefn(\moanSel, 0);
Pdefn(\moanSel, 1);
Pdefn(\moanSel, Pstep(Pseq([0, 1], inf), 8, inf));
Pdefn(\remRel, Pwhite(0.01, 0.05));
Pdefn(\remRel, Pwhite(0.01, 1.0));
Pdefn(\remPan, Pwhite(-0.2, 0.2));
Pdefn(\remPan, Pwhite(-1.0, 1.0));
Pdefn(\remAtk, Pwrand([0.1, 0.0], [0.8, 0.2], inf));
Pdefn(\remAtk, 0.0);
Pdefn(\remDur, Prand([1/4, 1/8, Prand([1/16, 1/8], inf)], inf)).quant_(2);
Pdefn(\kikDur, Prand([1/4, 1/8, Prand([1/16, 3/8], inf)], inf)).quant_(2);
Pdefn(\nhDur, Prand([1/4, 1/8, Prand([1/16, 3/8], inf)], inf)).quant_(2);
(
Pdefn(\remDur, 1/2).quant_(2);
Pdefn(\remPan, Pwhite(-1.0, 1.0));
)
 //orita vuelvo
(
Pdefn(\remDur, Pstep(Pseq([1/32, Prand([1/4, 1/8], inf)], inf))).quant_(2);
Pdefn(\kikDur, Pstep(Pseq([1/1, Prand([Rest(1/4), 1/2], inf)], inf))).quant_(2);
Pdefn(\kikDur, 1/1).quant_(2);
Pdefn(\rpDur, Pstep(Pseq([1/2, 1], inf))).quant_(2);
Pdefn(\nhDur, Pstep(Pseq([1/2, 1/4].reverse, inf))).quant_(2);
)
Pdefn(\remDur, 1/4).quant_(2);
Pdefn(\nhDur, 1/4).quant_(2);

~seqHat = ~pbindHat.play(t, quant: 4);
~seqKik1 = ~pbindKik1.play(t, quant: 2);

(
~seqNoiseHat = ~pbindNoiseHat.play(t, quant: 8);
~seqRhythmClicks = ~pbindRhythmClicks.play(t, quant: 8);
)

Pdefn(\kikAmp, Pwhite(0.5, 1.0));

~seqHat.stop; 
~seqKik1.stop;
~seqNoiseHat.stop;
Pdefn(\noiseHat, Pwhite(0.5, 2.0));

Synth(\noise1, [\pan, rrand(-1.0, 1.0), \amp, rrand(0.1, 1.0)]);
Synth(\noiseHat,[\amp, rrand(0.01, 0.8), \rel, rrand(0.01, 0.5)]);

s.record;
s.stopRecording;
