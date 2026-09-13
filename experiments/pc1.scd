// --- manual utility lines (evaluate individually with <M-e>) ---
s.quit({"--- Sound server has been stopped.".postln});
s.serverRunning;
s.freeAll;
MIDIClient.init;
MIDIClient.sources;
MIDIClient.disposeClient;

// --- setup: buses, clock, paths ---
(
s.waitForBoot({
  s.newBusAllocators;
  ~mixerBus = Bus.audio(s, 8);
  ~delayBus = Bus.audio(s, 2);
  ~reverbBus = Bus.audio(s, 2);

  // create the clock only once; survives re-evaluation of this block
  t ?? { t = TempoClock(120/60).permanent_(true) };

  // main sound directories:
  ~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";

  "--- Executed function inside s.waitForBoot;".postln;
});
)

// --- SynthDefs ---
(
SynthDef(\simpleBleep, {
  | amp = 1.0,
    pan = 0.0,
    atk = 0.01,
    rel = 0.01,
    freq = 800 |
  var sig = SinOsc.ar(freq);
  var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
  sig = sig * env * amp;
  sig = Limiter.ar(sig);
  Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

// --- patterns ---
(
~pbindBleeps = Pbind(
  \instrument, \simpleBleep,
  \atk, 0.0,
  \amp, Pwhite(0.01, 1.0),
  \rel, 0.1,
  \dur, 1/4,
  \pan, 0
);
)

// --- performance lines (evaluate individually) ---
~seqBleeps = ~pbindBleeps.play(t, quant: 1);
~seqBleeps.stop;

(
~pbindBleeps2 = Pbind(
  \instrument, \simpleBleep,
  \atk, 0.0,
  \freq, 1000,
  \amp, Pwhite(0.01, 1.0),
  \rel, 0.1,
  \dur, 1/2,
  \pan, 0
);
)
~seqBleeps2 = ~pbindBleeps2.play(t, quant: 1);
~seqBleeps2.stop;

(
~pbindBleeps3 = Pbind(
  \instrument, \simpleBleep,
  \atk, 0.0,
  \freq, 3000,
  \amp, Pwhite(0.01, 1.0),
  \rel, 0.1,
  \dur, Prand([1/1, 1/2, 1/4], inf),
  \pan, 0
);
)
~seqBleeps3 = ~pbindBleeps3.play(t, quant: 1);
~seqBleeps3.stop;
// --- monitoring (open manually, close when done) ---
s.plotTree;
s.meter;

// --- recording ---
s.record;
s.stopRecording;
