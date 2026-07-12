s.boot;
s.quit({"--- Sound server has been stopped.".postln});
s.serverRunning;
s.freeAll;
s.plotTree;
s.meter;

s.record;
s.stopRecording;

// bus (canales de audio) creation:
(
  s.newBusAllocators;
  ~mixerBus = Bus.audio(s, 8);
  ~delayBus = Bus.audio(s, 2);
  ~reverbBus = Bus.audio(s, 2);
)

(
s.waitForBoot({
  
  t = TempoClock(100/60).permanent_(true);

  // main sound directories:
  ~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";

  // individual sample files:
  ~kik1 = Buffer.read(s, ~soundDir +/+ "kik1.wav");
  ~hat1 = Buffer.read(s, ~soundDir +/+ "hat.wav");
  ~pad1 = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav");
  ~pad2 = Buffer.read(s, ~soundDir +/+ "luz.wav");
  ~kik2 = Buffer.read(s, ~soundDir +/+ "kik2.wav");
  ~deepKik = Buffer.read(s, ~soundDir +/+ "deepkik1.wav");

  // Gemidos de Elizabeth mientras se masturba para mí:
  ~elig1 = Buffer.read(s, ~soundDir +/+ "eligem1.wav");
  ~elig2 = Buffer.read(s, ~soundDir +/+ "eligem2.wav");
  ~elig3 = Buffer.read(s, ~soundDir +/+ "eligem3.wav");
  ~elig4 = Buffer.read(s, ~soundDir +/+ "eligem4.wav");
  ~elig5 = Buffer.read(s, ~soundDir +/+ "eligem5.wav");
  ~elig6 = Buffer.read(s, ~soundDir +/+ "eligem6.wav");

  ~eliGemidos = [
    ~elig1,
    ~elig2,
    ~elig3,
    ~elig4,
    ~elig5,
    ~elig6,
  ];

  ~pigPad1 = Buffer.read(s, ~soundDir +/+ "pad-gritty-melancholic1.wav");
  ~pigPad2 = Buffer.read(s, ~soundDir +/+ "pad-gritty-melancholic2.wav");

  s.sync;
  "--- Executed function inside s.waitForBoot;".postln;
});
)
// ------------------

// SynthDefs:

// sfx busses:

(
  SynthDef(\busReverb, { | in = 0, out = 0, size = 0.27 |
    var sig = In.ar(in, 2);
    sig = FreeVerb2.ar(sig[0], sig[1], mix: 1.0, room: size);
    Out.ar(out, sig);
  }).add;
)

(
  ~reverbSynth = Synth(\busReverb, [in: ~reverbBus, out: 0], addAction: \addToTail);
)

// Pad sample with Playbuf
(
  SynthDef(\wavPb, { |buf, rate = 1.0, pan = 0.0, atk = 0.01, rel = 1.0|
    var sig, env;
    env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = PlayBuf.ar(2, buf, rate, doneAction: 2);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;
)

Synth(\wavPb, [buf: ~pigPad1, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\wavPb, [buf: ~pigPad2, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);

// Pad sample with GrainBuf
(
  SynthDef(\wavPbGrain, { |buf, rate = 1.0, pan = 0.0, atk = 0.01, rel = 1.0|
    var sig, env;
    env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = PlayBuf.ar(2, buf, rate, doneAction: 2);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;
)

Synth(\wavPbGrain, [buf: ~pigPad1, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\wavPbGrain, [buf: ~pigPad2, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);


// noise with filter #1:
(
  SynthDef(\noise1, { |sweepTime = 10.0, amp = 1.0, pan = 0.0|
    var sig, env, cutoff, ampMod, panMod;
    cutoff = XLine.kr(1500, 20000, sweepTime, doneAction: 2);
    env = EnvGen.kr(
      Env.new(
        levels: [0, ExpRand(0.3, 0.6), 0],
        times: [ExpRand(0.3, 1.0), ExpRand(0.5, 5.0)],
        curve: [4, -4]
      ),
      doneAction: 2
    );
    panMod = SinOsc.kr(Rand(0.1, 1.0).range(0.1, 0.15), Rand(0.1, 0.9));
    ampMod = SinOsc.kr(Rand(0.1, 1.0).range(0.1, 0.5), Rand(0.1, 0.9));
    sig = WhiteNoise.ar(1.0);
    sig = HPF.ar(sig, cutoff);
    sig = sig * env * amp * ampMod;
    sig = Pan2.ar(sig, pan * panMod);
    
    sig = Limiter.ar(sig);
    Out.ar(0, sig) 
  }).add;
)

Synth(\noise1, [\pan, rrand(-1.0, 1.0), \amp, rrand(0.1, 1.0)]);

// gemido con reverb:
(
SynthDef(\eliGemRev, { |buf, pan = 0, rate = 1.0, startPos = 0, mix = 0.4, room = 0.1, amp = 1.0, delTime = 0.375, decay = 2.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos, doneAction: 2);
    // echo: delTime in seconds, decay = tail length
    sig = sig + CombL.ar(sig, 1.0, delTime, decay);
    sig = FreeVerb.ar(sig, mix, room, 0.5);
    sig = sig * SinOsc.kr(Rand(0.1, 2.0).range(0.1, 2.0));
    sig = Limiter.ar(sig * amp);
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
}).add;
)

(
  SynthDef(\tone1, {|mainPitch = 1|
	var sig, freqs, amps, phases, root, ratios;
  var env = EnvGen.kr(
    envelope: Env.new(
    levels: [0, ExpRand(0.1, 0.2), 0],
    times: [ExpRand(0.01, 1.0), ExpRand(0.5, 5.0)],
    curve: [4, -4]
    ),
    doneAction: 2
  )
	root = 210; // lower fundamental for warmth
	// Just-intonation ratios: root, maj9, maj3, 5, 6, maj7 (consonant, nostalgic)
	ratios = [1, 9/8, 5/4, 3/2, 5/3, 15/8];
	// Build 10 freqs by picking chord tones and transposing up per group
	freqs = Array.fill(10, { |i|
		root * ratios.choose * (2 ** (i.div(ratios.size)));
	});
	amps = Array.exprand(10, 0.005, 0.2).sort.reverse;
	phases = Array.rand(10, 0, 2pi);
	sig = DynKlang.ar(`[
		mainPitch * freqs * LFNoise2.kr(Rand(0.02, 0.05) ! 10).exprange(0.995, 1.005), // very subtle drift keeps layers coherent
		amps * LFNoise1.kr(1 ! 10).exprange(0.2, 1),
		phases
	]);
	sig = Pan2.ar(sig, SinOsc.kr(exprand(0.1, 0.5), exprand(1, 10)).range(1.0, -1.0));
  sig = sig * env;
	sig = Limiter.ar(sig);
	sig = LeakDC.ar(sig);
  Out.ar(0, sig);
}).add;
)

(
  SynthDef.new(\wav1, {|buf, amp= 1.0, pan = 0.0, rate = 1.0, startPos = 0, atk = 0.01, rel = 0.01, cutoff = 1.0, revSend = 1.0|
  var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos);
  var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
  sig = sig * env;
  sig = HPF.ar(sig, XLine.kr(Rand(0, 200), 20000, Rand(0.5, 1.0)), Rand(0.5, 1.0));
  sig = Limiter.ar(sig); 
  Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  Out.ar(~reverbBus, sig * revSend);
  }).add;
)

(
SynthDef.new(\sKik1,{ |buf, rate = 1.0, pan = 0.0, atk = 0.0, rel = 1.0|
var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate);
var lineTime = Rand(0.1, 1.0);
var mod = SinOsc.kr(0.2, 3pi/2).exprange(0.01,0.5);
var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
sig = sig * env;
sig = LPF.ar(sig, XLine.kr(Rand(0, 10000), 20000, lineTime), lineTime);
sig = sig.round(mod);
sig = Limiter.ar(sig); 
Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
}).add;
)

(
SynthDef.new(\noiseHat, { |amp = 0.5, rel = 1.0, cutoff = 1.0, pan = 0.0|
  var sig = WhiteNoise.ar(0.1 ! 2);
  var lineTime = Rand(0.1, 1.0);
  var env = EnvGen.kr(Env.perc(0.01, rel, 1, 1),doneAction: 2);
  sig = sig * env;
  sig = HPF.ar(sig, XLine.kr(Rand(0, 10000), 20000, lineTime), lineTime);
  sig = Pan2.ar(sig, pan);
  sig = Limiter.ar(sig);
  Out.ar(0, Balance2.ar(sig[0], sig[1], 0.0));
}).add;
)


Synth(\noiseHat,[\amp, rrand(0.01, 0.2), \rel, rrand(0.01, 0.5)]);

// Pbinds:
(
var pad1StartPos = Pdup(16, Pwhite(0, ~pad1.numFrames));
var dur1 = Pseq([1,Prand([1/4, Rest(1/4)], inf), Rest(1/2), Prand([Rest(1/2), 1/2, 1/4], 1)], inf);
var durs = Array.geom(rrand(3, 6), 1, rrand(0.5, 0.8));
~kick = Pbind(
    \instrument, \sKik1,
    \startPos, 0,
    \buf, ~kik2,
    \rel, Pwhite(0.1, 0.2),
    \rate, 1.0,
    \dur, Pseq([1, Rest(1/2), 1/4, Rest(1/2)], inf)
);

~pbindEliGemidos = Pbind(
    \instrument, \wav1,
    \startPos, 0,
    \buf, Prand(~eliGemidos, inf),
    \rel, Pwhite(0.1, 0.2),
    \rate, 1.0,
    \pan, 0.0,
    \dur, dur1 
);

~pbindEliGemRev = Pbind(
    \instrument, \eliGemRev,
    \startPos, 0,
    \buf, Prand(~eliGemidos, inf),
    \rate, Prand([1, 1.02, 0.98], inf),
    \pan, Pbrown(-1.0, 1.0, 1.0),
    \mix, Pwhite(0.1, 1.0),
    \room, Pwhite(0.5, 0.95),
    \delTime, Prand([1/8, 3/16, 1/4, 3/4] * 4, inf) * Pfunc({ t.beatDur }),
    \decay, Pwhite(1.0, 2.0),
    \amp, Pwhite(0.5, 1.0),
    \dur, Pseq([1, Rest(1), Prand([1, 1/2], 1)], inf)
);

~deepKik = Pbind(
    \instrument, \sKik1,
    \startPos, 0,
    \buf, ~deepKik,
    \rel, Pwhite(0.1, 0.2),
    \rate, 1.0,
    \dur, dur1
);

~pbindPad1 = Pbind(
  \instrument, \wavPb,
  \buf, ~pigPad1,
  \atk, 0.0,
  \rel, Pwhite(0.1, 1.0),
  \startPos,pad1StartPos,
  \rate, 1.0,
  \dur, Pseq([1, Rest(1/2), 1/4, Prand([1/4, Rest(1/2)], 1)], inf),
  \pan, Pwhite(-0.2, 0.2)
);
~pbindPad2 = Pbind(
  \instrument, \wavPb,
  \buf, ~pigPad2,
  \atk, 0.0,
  \amp, Pwhite(0.1, 0.8),
  \rel, Pwhite(0.01, 0.05),
  \startPos,pad1StartPos,
  \rate, 1.0,
  \dur, 1/4,
  \pan, Pwhite(-0.2, 0.2)
);

~pbindHat = Pbind(
  \instrument, \wav1,
  \buf, ~hat1,
\rel, Pwhite(0.05, 0.2),
  \amp, Pwhite(0.1, 1.0),
  \startPos, 0,
  \rate, 1.0,
  \dur, Prand([1/4, Rest(1/2)], inf),
  \pan, Pwhite(-0.5, 0.5)
);

~pbindNoiseHat = Pbind(
  \instrument, \noiseHat,
  \amp, Pwhite(0.1, 1.0),
  \rel, Pwhite(0.01, 0.1),
  \dur, 1/4,
  \pan, Pwhite(-1.0, 1.0);
);
)

// Gritty pad sequential event:
(
  var padsStartPos = Pdup(8, Pwhite(0, ~pigPad1.numFrames));

  ~pbindPad1 = Pbind(
  \instrument, \wavPb,
  \buf, ~pigPad1,
  \atk, 0.0,
  \rel, Pwhite(0.1, 1.0),
  \startPos,padsStartPos,
  \rate, 1.0,
  \dur, Pseq([1, Rest(1/2), 1/4, Prand([1/4, Rest(1/2)], 1)], 8),
  \pan, Pwhite(-0.2, 0.2)
  );   
    
  ~pbindPad2 = Pbind(
    \instrument, \wavPb,
    \buf, ~pigPad2,
    \atk, 0.0,
    \amp, Pwhite(0.1, 0.8),
    \rel, Pwhite(0.1, 1.0),
    \startPos,padsStartPos,
    \rate, 1.0,
    \dur, Pseq([1, Rest(1/2), 1/4, Prand([1/4, Rest(1/2)], 1)], 8),
    \pan, Pwhite(-0.2, 0.2)
  );

  ~grittyPadSeqEvent = Pseq([
    Pfindur(8, ~pbindPad1),
    Pfindur(8, ~pbindPad2),
  ], inf);
)

// Sequential code:
t = TempoClock(100/60).permanent_(true);

(
  ~seqEliGemidos = ~pbindEliGemidos.play(t);
  ~seqKik = ~kick.play(t);
  ~seqEliGemRev = ~pbindEliGemRev.play(t); 
  ~seqNoiseHat = ~pbindNoiseHat.play(t);
  ~seqGrittyPads = ~grittyPadSeqEvent.play(t);
  ~seqHat = ~pbindHat.play(t);
)

s.record;
s.stopRecording;

// Pattern studies ----------------------------------------

(
  ~pat = Pwhite(0.0, 1.0, inf) * Pseq([-1, 1], inf);
  ~seq = ~pat.asStream.nextN(8);
)

// Granular synthesis:


