
s.boot;
s.stop;
s.freeAll;
s.plotTree;
s.meter;

s.record;
s.stopRecording;

t = TempoClock(140/60).permanent_(true);

// main sound directories:
(
~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
)

// individual sample files:
(
~kik1 = Buffer.read(s, ~soundDir +/+ "kik1.wav");
~eliMorirT1 = Buffer.read(s, ~soundDir +/+ "eli-morir-t1.wav");
~pad1 = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav");
)
~pad2 = Buffer.read(s, ~soundDir +/+ "luz.wav");
// ------------------

// SynthDef:

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
  );
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
SynthDef.new(\wav1, {|buf, pan = 0.0, rate = 1.0, startPos = 0, atk = 0.01, rel = 0.01, cutoff = 1.0|
var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos);
var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
sig = sig * env;
sig = HPF.ar(sig, XLine.kr(Rand(0, 200), 20000, Rand(0.5, 1.0)), Rand(0.5, 1.0));
sig = Limiter.ar(sig); 
Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
}).add;
)

(
SynthDef.new(\noiseHat, { |amp = 0.5, rel = 0.5, cutoff = 1.0|
  var sig = WhiteNoise.ar(0.1 ! 2);
  var env = EnvGen.kr(Env.perc(0.01, rel, 1, 1),doneAction: 2);
  sig = sig * env;
  sig = HPF.ar(sig, XLine.kr(Rand(0, 200), 20000, 0.5), Rand(0.5, 1.0));
  sig = Limiter.ar(sig);
  Out.ar(0, Balance2.ar(sig[0], sig[1], 0.0));
}).add;
)

Synth(\wav1, [buf: ~eliMorirT1, atk: rrand(0.01, 0.05), rel: rrand(0.1, 1.0), startPos: rrand(0, ~eliMorirT1.numFrames), rate: [-1.0, 1.0].choose]);

Synth(\wav1,[buf: ~kik1, rel: rrand(0.1, 1.0), rate: [0.1, 1.0].choose]);

Synth(\noiseHat,[\amp, rrand(0.01, 0.2), \rel, rrand(0.01, 0.5)]);

// Pbinds:
(
var randomStartPosS1 = Pdup(16, Pwhite(0, ~eliMorirT1.numFrames));
var randomStartPosP1 = Pdup(16, Pwhite(0, ~pad1.numFrames));
var randomStartPosP2 = Pdup(16, Pwhite(0, ~pad2.numFrames));
var randomDurS1 = Pdup(8, Pwrand([1/2, 1/4, 1/8],[0.1, 0.8, 0.1], inf));
~sample1 = Pdef(\sample1,Pbind(
  \instrument, \wav1,
  \buf, ~eliMorirT1,
  \atk, 0.0,
  \rel, Pwhite(0.01, 0.2),
  \startPos, randomStartPosS1,
  \rate, 1.0,
  \dur, 1/4,
  \pan, Pwhite(-1.0, 1.0)
));

~kick = Pbind(
    \instrument, \wav1,
    \startPos, 0,
    \buf, ~kik1,
    \rel, Pwhite(0.1, 1.0),
    \rate, 1.0,
    \dur, 1/2
);

~pbindPad1 = Pbind(
  \instrument, \wav1,
  \buf, ~pad2,
  \atk, 0.0,
  \rel, Pwhite(0.1, 0.2),
  \startPos, randomStartPosP2,
  \rate, 1.0,
  \dur, 1/4,
  \pan, Pwhite(-0.2, 0.2)
);
~pbindNoiseHat = Pbind(
  \instrument, \noiseHat,
  \amp, Pwhite(0.01, 0.02),
  \rel, Pwhite(0.01, 0.08),
  \dur, 1/4,
);
)


(
~seqLayer1 = Pdef(\sample1).play(t);
~seqKick = ~kick.play(t);
~seqNoiseHat = ~pbindNoiseHat.play(t);
)

~currentRate = 1.0;
~m1CurrentRate = 1.0;
(
Pdef(\sample1, Pbind(
  \instrument, \wav1,
  \buf, ~eliMorirT1,
  \atk, 0.0,
  \rel, Pwhite(0.1, 0.2),
  \startPos, Pwhite(0, ~eliMorirT1.numFrames),
  \rate, Pfunc({ ~currentRate }),  // reads the var on every event
  \dur, 1/4,
  \pan, Pwhite(-1.0, 1.0)
));

Pdef(\melodia1, Pbind(
  \instrument, \wav1,
  \buf, ~pad1,
  \atk, 0.0,
  \rel, Pwhite(0.1, 0.2),
  \startPos, Pwhite(0, ~pad1.numFrames),
  \rate, Pfunc({ ~m1CurrentRate }),  // reads the var on every event
  \dur, 1/4,
  \pan, Pwhite(-1.0, 1.0)
));
)

