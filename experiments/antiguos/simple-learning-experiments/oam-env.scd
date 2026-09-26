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
sig = SinOsc.ar(freq * pitchMul)  * env * ampMod;
sig = Pan2.ar(sig, Rand(-1.0, 1.0));
Out.ar(0, sig);
}).add;
};
)

(10.do {|i| Synth(("notes"++i).asSymbol)};)

s.record;
s.stopRecording;
