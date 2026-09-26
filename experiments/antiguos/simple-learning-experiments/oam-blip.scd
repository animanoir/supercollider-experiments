s.boot;
s.stop;
s.freeAll;
s.plotTree;

(
{
// Double harmonic (Byzantine/oriental) scale on A
var freqArray = [220.0, 233.08, 277.18, 293.66, 329.63, 349.23, 415.30, 440.0];
var sig, env;
env = XLine.kr(start: 0.1, end: 0.001, dur: exprand(0.1, 5.0), doneAction: Done.freeSelf);
sig = SinOsc.ar(freqArray.choose) * env;
sig = sig ! 2;
}.play;
)


(
SynthDef(\notes1, {
// Double harmonic (Byzantine/oriental) scale on A
var freqArray = [220.0, 233.08, 277.18, 293.66, 329.63, 349.23, 415.30, 440.0];
var sig, env;
var freq = Select.kr(Rand(0, freqArray.size).floor, freqArray);
env = XLine.kr(start: 0.1, end: 0.001, dur: ExpRand(0.1, 5.0), doneAction: Done.freeSelf);
sig = SinOsc.ar(freq) * env;
sig = Pan2.ar(sig, Rand(-1.0, 1.0));
Out.ar(0, sig);
}).add;
)

~notes1 = Synth(\notes1);


(
10.do{ |i|
SynthDef(("notes"++i), {
// pitch select:
var roll = Rand(0, 3).floor;
var pitchMul = Select.kr(roll, [1, 2, 0.5], 3);
// Hirajoshi (Japanese pentatonic) on A
var freqArray = [220.0, 246.94, 261.63, 329.63, 349.23, 440.0];
var sig;
var harm;
var lfFreq;
var randomPhase;
var ampMod = SinOsc.kr(Rand(0.5, 8)).range(0.2, 1.0);
var freq = Select.kr(Rand(0, freqArray.size).floor, freqArray);
var env = EnvGen.kr(
  envelope: Env.new(
    levels: [0, ExpRand(0.1, 1.0), 0],
    times: [ExpRand(0.01, 5.0), ExpRand(0.5, 5.0)],
    curve: [4, -4]
  ),
  doneAction: 2
);
lfFreq = Rand(0.01, 0.05);

randomPhase = Rand(1, 10);
harm = LFTri.kr(lfFreq, randomPhase).range(1, 5);
sig = SinOsc.ar(freq * pitchMul)  * env * ampMod;
sig = sig * Blip.ar([180, 181], harm);
sig = Pan2.ar(sig, Rand(-1.0, 1.0));
Out.ar(0, sig);
}).add;
};
)

(5.do {|i| Synth(("notes"++i).asSymbol)};)


//Blip
(
f = { |lfFreq = 0.1|
var sig, harm;
harm = LFPar.kr(lfFreq, 3).range(1, 100);
sig = Blip.ar([80, 81], harm);
sig * 0.1;
}
)

x = f.play;
x.set(\lfFreq, 0.1);


(
{
	var sig;
	sig = Klang.ar(
		`[	// <- note the backtick character
			Array.exprand(40, 50, 8000).sort,
			Array.exprand(40, 0.001, 0.05).sort.reverse,
			Array.rand(40, 0, 2pi)
		]
	);
	sig = sig ! 2;
}.play;
)

// DynKlang exampple:
(
{
	var sig, freqs, amps, phases;
	freqs = Array.exprand(40, 50, 8000);
	amps = Array.exprand(40, 0.005, 0.2).sort.reverse;
	phases = Array.rand(40, 0, 2pi);
	sig = DynKlang.ar(`[ // <- note the backtick character
		freqs * LFNoise1.kr(0.02 ! 40).exprange(0.25, 2),
		amps * LFNoise1.kr(1 ! 40).exprange(0.02, 1),
		phases
	]);
  sig = Pan2.ar(sig, SinOsc.kr(exprand(1, 10), exprand(1, 10)).range(-1.0, 1.0));
}.play;
)

(
{
	var sig, freqs, amps, phases;
	freqs = Array.exprand(40, 50, 8000).sort;
	amps = Array.exprand(40, 0.005, 0.2).sort.reverse;
	phases = Array.rand(40, 0, 2pi);
	sig = DynKlang.ar(`[ // <- note the backtick character
		freqs * LFNoise1.kr(0.02 ! 40).exprange(0.25, 2),
		amps * LFNoise1.kr(1 ! 40).exprange(0.02, 1),
		phases
	]);
  sig = Pan2.ar(sig, SinOsc.kr(exprand(1, 10), exprand(1, 10)).range(1.0, -1.0));
}.play;
)

(
{
	var sig, scales, freqs, amps, phases, scale, root;
	root = 220; // A3 as fundamental
	// Hijaz-like intervals in semitones over 2 octaves
  scales = [
    [0, 1, 4, 5, 7, 8, 11, 12, 13, 16, 17, 19, 20, 23], // Hijaz
    [0, 2, 3, 5, 7, 8, 11, 12, 14, 15, 17, 19, 20, 23], // Nahawand
    [0, 1, 3, 5, 7, 8, 10, 12, 13, 15, 17, 19, 20, 22], // Kurd
    [0, 2, 3, 6, 7, 9, 10, 12, 14, 15, 18, 19, 21, 22], // Nikriz
    [0, 1, 4, 5, 7, 8, 11, 12, 13, 16, 17, 19, 20, 23]  // Hijaz Kar
];
scale = scales.choose;
	// Build 40 freqs by picking scale degrees and transposing up
	freqs = Array.fill(10, { |i|
		root * (2 ** (scale.choose / 12)) * (2 ** (i.div(scale.size)));
	});
	amps = Array.exprand(10, 0.005, 0.2).sort.reverse;
	phases = Array.rand(10, 0, 2pi);
	sig = DynKlang.ar(`[
		freqs * LFNoise2.kr(Rand(0.02, 0.05) ! 10).exprange(0.98, 1.0), // subtle detune to keep pitches recognizable
		amps * LFNoise1.kr(1 ! 10).exprange(0.2, 1),
		phases
	]);
	sig = Pan2.ar(sig, SinOsc.kr(exprand(0.1, 0.5), exprand(1, 10)).range(1.0, -1.0));
  sig = Limiter.ar(sig);
  sig = LeakDC.ar(sig);
}.play;
)

(
  SynthDef(\tone1, {|mainPitch = 1|
	var sig, freqs, amps, phases, root, ratios;
  var env = EnvGen.kr(
    envelope: Env.new(
    levels: [0, ExpRand(0.1, 0.2), 0],
    times: [ExpRand(0.01, 5.0), ExpRand(0.5, 5.0)],
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
f = {
  132.do({
    Synth(\tone1);
    rrand(0.1,0.8).yield;
  })
};

~routine1 = Routine(f);
)

(
f = {
  132.do({
    [1, 1.5, 2, 0.5].do({ |p| Synth(\tone1, [\mainPitch, p]) }); // chord per trigger
    rrand(0.1, 0.8).yield;
  })
};
~routine1 = Routine(f);
)
~routine1.play;

s.record;
s.stopRecording;
