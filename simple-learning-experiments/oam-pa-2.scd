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
  ~mixerBus = Bus.audio(s, 8);
  ~delayBus = Bus.audio(s, 2);
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
    ~p1wav,
    ~p2wav,
    ~p3wav,
    ~p4wav,
    ~p5wav,
    ~p6wav,
    ~p7wav,
  ];

  ~pMono = Buffer.readChannel(s, ~soundDir +/+ "pg1.wav", channels: [0]);
 // ---- SynthDefs ----
// ---------------------------------------------------------------
(
  SynthDef.new(\simpleBuf){ | buf, pan = 0.0, atk = 0.0, rel = 1.0 |

    var sig, env;
    env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf), 1.0);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }.add; 
)

Synth(\simpleBuf, [buf: ~eliGemidos.choose ]);


(
var moanSelection = 0;
var selectedBuf = Pdup(4, Prand(~eliGemidos, inf));
~randomEliMoans = Pbind(
  \instrument, \simpleBuf,
  \dur, 1/4,
  \moanSelecto, 0,
  \buf, if(moanSelection == 0, {selectedBuf}, Prand(~eliGemidos, inf)),
  \atk, Pwrand([0.0, 0.1], [0.8, 0.2], inf),
  \pan, Pwhite(-0.5, 0.5)
);
)

(
var selectedBuf = Pdup(4, Prand(~pigPads, inf));
~repeatingBuf2 = Pbind(
  \instrument, \simpleBuf,
  \dur, 1/2, 
  \rel, Pwhite(0.5, 1.0),
  \buf, selectedBuf,
  \atk, Pwrand([0.5, 0.1], [0.8, 0.2], inf),
  \pan, Pwhite(-0.5, 0.5)
);
)

(
~pbindKik1 = Pbind(
  \instrument, \sKik1,
  \dur, Pseq([1/2, 1/2, 1/4], inf),
)
)

(
~seqRepeatingBuf1 = ~repeatingBuf1.play(t);
~seqRepeatingBuf2 = ~repeatingBuf2.play(t);
)
~seqRandomEliMoans = ~randomEliMoans.play(t).quant_(4);
(
~seqHat = ~pbindHat.play(t, quant: 4);
~seqKik1 = ~pbindKik1.play(t, quant: 4);
~seqNoiseHat = ~pbindNoiseHat.play(t, quant: 4);
)
// --------------------------------------------------------------

  // pad sample with PlayBuf
  SynthDef(\wavPb, { |buf, rate = 1.0, pan = 0.0, atk = 0.01, rel = 1.0|
    var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    var sig = PlayBuf.ar(2, buf, rate);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;

  // noise with sweeping filter
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
    Out.ar(0, sig);
  }).add;

  // gemido con reverb + echo
  SynthDef(\eliGemRev, { |buf, pan = 0, rate = 1.0, startPos = 0, mix = 0.4,
    room = 0.1, amp = 1.0, delTime = 0.375, decay = 2.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos, doneAction: 2);
    sig = sig + CombL.ar(sig, 1.0, delTime, decay);
    sig = FreeVerb.ar(sig, mix, room, 0.5);
    sig = sig * SinOsc.kr(Rand(0.1, 2.0).range(0.1, 2.0));
    sig = Limiter.ar(sig * amp);
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
  }).add;

  // just-intonation additive tone
  SynthDef(\tone1, { |mainPitch = 1|
    var sig, freqs, amps, phases, root, ratios;
    var env = EnvGen.kr(
      Env.new(
        levels: [0, ExpRand(0.1, 0.2), 0],
        times: [ExpRand(0.01, 1.0), ExpRand(0.5, 5.0)],
        curve: [4, -4]
      ),
      doneAction: 2
    );
    root = 210; // lower fundamental for warmth
    // just-intonation ratios: root, maj9, maj3, 5, 6, maj7
    ratios = [1, 9/8, 5/4, 3/2, 5/3, 15/8];
    freqs = Array.fill(10, { |i|
      root * ratios.choose * (2 ** (i.div(ratios.size)));
    });
    amps   = Array.exprand(10, 0.005, 0.2).sort.reverse;
    phases = Array.rand(10, 0, 2pi);
    sig = DynKlang.ar(`[
      mainPitch * freqs * LFNoise2.kr(Rand(0.02, 0.05) ! 10).exprange(0.995, 1.005),
      amps * LFNoise1.kr(1 ! 10).exprange(0.2, 1),
      phases
    ]);
    sig = Pan2.ar(sig, SinOsc.kr(exprand(0.1, 0.5), exprand(1, 10)).range(1.0, -1.0));
    sig = sig * env;
    sig = Limiter.ar(sig);
    sig = LeakDC.ar(sig);
    Out.ar(0, sig);
  }).add;

  // main buffer voice with reverb send
  SynthDef(\wav1, { |buf, amp = 1.0, pan = 0.0, rate = 1.0, startPos = 0,
    atk = 0.01, rel = 0.01, cutoff = 1.0, revSend = 1.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = sig * env;
    sig = HPF.ar(sig, XLine.kr(Rand(0, 200), 20000, Rand(0.5, 1.0)), Rand(0.5, 1.0));
    sig = Limiter.ar(sig);
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
    Out.ar(~reverbBus, sig * revSend);
  }).add;

  // kick from sample
  SynthDef(\sKik1, { |buf, rate = 1.0, pan = 0.0, atk = 0.0, rel = 1.0|
    var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate);
    var lineTime = Rand(0.1, 1.0);
    var mod = SinOsc.kr(0.2, 3pi/2).exprange(0.01, 0.5);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, 1), doneAction: 2);
    sig = sig * env;
    sig = LPF.ar(sig, XLine.kr(Rand(0, 10000), 20000, lineTime), lineTime);
    sig = sig.round(mod);
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
  
  SynthDef(\granWav1, { |buf|
  var sig;
  sig = GrainBuf.ar(
    2,
    Impulse.kr(8),
    0.05,
    buf,
    rate: 7.midiratio,
    pos: Line.kr(0, 1,BufDur.ir(buf), doneAction: 2),
  );
  Out.ar(0, sig)
  }).add;

  s.sync;
  "--- Executed function inside s.waitForBoot;".postln;
});
)
// --------------------------------------------------------------------

Synth(\noise1, [\pan, rrand(-1.0, 1.0), \amp, rrand(0.1, 1.0)]);
Synth(\sKik1, [\pan, rrand(-0.1, 0.1), \amp, rrand(0.9, 1.0)]);

(
  ~kikPadRoutine = {
    inf.do{
     var wChoose = [1, 3/2].choose;
     Synth(\sKik1, [\pan, rrand(-1.0, 1.0), \amp, rrand(0.1, 1.0)]);
     Synth(\wavPb, [\buf, ~pigPad1 ,\pan, rrand(-1.0, 1.0), \amp, rrand(0.1, 1.0)]);
     //Synth(\wavPb, [buf: ~pWavs.choose, rate: 0.5,atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
     ([wChoose, 1/2].choose).yield;
    }
  };
  ~kik1Player = Routine(~kikPadRoutine);
)

(
~kik44Routine = {
    inf.do{
     Synth(\sKik1, [\pan, rrand(-0.1, 0.1), \amp, rrand(0.1, 1.0)]);
     //Synth(\wavPb, [buf: ~pWavs.choose, rate: 0.5,atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
     1.yield;
    }
  };
~kik44Player = Routine(~kik44Routine);
)

(
~kik44Player.play(t);
~kik44Player.stop;
~hihatPlayer.play(t);
)
(
  ~hihat = {
    inf.do{
     Synth(\noiseHat,[\amp, rrand(0.5, 1.0), \rel, rrand(0.01, 0.1)]);
     (1/2).yield;
    }
  }
)


(
  ~hihat = {
    inf.do{
     Synth(\noiseHat,[\amp, rrand(0.5, 1.0), \rel, rrand(0.01, 0.1)]);
     (1/2).yield;
    }
  }
)

t = TempoClock(150/60).permanent_(true);

~hihatPlayer = Routine(~hihat);
(
~kik1Player.play(t);
~hihatPlayer.play(t);
)

~kik1Player.stop(t);
~kik1Player.reset(t);


Synth(\wavPb, [buf: ~pigPad1, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\wavPb, [buf: ~pigPad2, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\wavPb, [buf: ~pWavs.choose, rate: 0.5,atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\granWav1, [buf: ~pMono]);

Synth(\wavPbGrain, [buf: ~pigPad1, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);
Synth(\wavPbGrain, [buf: ~pigPad2, atk: rrand(0.01, 0.08), rel: rrand(0.1, 1.0)]);

(
  ~reverbSynth = Synth(\busReverb, [in: ~reverbBus, out: 0], addAction: \addToTail);
)


Synth(\noiseHat,[\amp, rrand(0.01, 0.8), \rel, rrand(0.01, 0.5)]);

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


