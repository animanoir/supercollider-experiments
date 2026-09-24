s.boot;
s.plotTree;
s.freeAll;

ClassBrowser.new()
t = TempoClock(140/60).permanent_(true);

(
~soundDirPath = PathName.new("/Users/oscarmontiel/documents/GitHub/scoll/wavs");
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
)

~sample1 = Buffer.read(s, ~soundDir +/+ "tuyateveniste.wav"); 

// shows all the files inside the specified folder:
(
~soundDirPath.files.do({|files|
  files.postln;
});
)

(
SynthDef(\glitchBuf, {
  |startPos = 0, rel = 0.08, buf, pan = 0.0, rate = 1.0|
  var sig, env;
  env = EnvGen.kr(Env.perc(0.001, releaseTime: rel), doneAction: 2);
  sig = PlayBuf.ar(2, buf, startPos: startPos, loop: 0, rate: rate,  doneAction: 2);
  sig = sig * env;
  Out.ar(0, Balance2.ar(sig[0], sig[1], pan))
}).add;
)

(
Synth(\glitchBuf, [
  \buf, ~sample1, 
  \startPos: rrand(0, ~sample1.numFrames - 1),
]);
)

(
~pb1 = Pbind(
  \instrument, \glitchBuf,
  \buf, ~sample1,
  \dur, Pdefn(\pb1Dur, 1/2),
  \startPos, Pdefn(\pb1StartPos, 0),
  \pan, Pseq([-1.0, 1.0, Pwhite(-1.0, 1.0, 1)], inf)
)
)

(
~pb2 = Pbind(
  \instrument, \glitchBuf,
  \buf, ~sample1,
  \dur, Pdefn(\pb2Dur, 1/4),
  \startPos, Pdefn(\pb2StartPos, Pwhite(0, ~sample1.numFrames - 1)),
  \pan, Pdefn(\pb2Pan, Pwhite(-0.01, 0.01, inf)),
  \rel, Pdefn(\pb2Rel, 0.08)
)
)


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

(
var randStartPos = Pwhite(0,~sample1.numFrames - 1);
~pb3 = Pbind(
  \instrument, \glitchBuf,
  \buf, ~sample1,
  \dur, Pdefn(\pb2Dur, 1/4),
  \startPos, Pdefn(\pb2StartPos, Pwhite(0, ~sample1.numFrames - 1)),
  \pan, Pdefn(\pb2Pan, Pwhite(-0.01, 0.01, inf)),
  \rel, Pdefn(\pb2Rel, 0.08)
)
)

(
~pb1.play(t, quant: 2);
~pb2.play(t, quant: 2);
)

(
Pdefn(\pb2Dur, 1/2).quant_(4);
Pdefn(\pb2Rel, 0.5).quant_(4);
Pdefn(\pb2Pan, Pfunc({sin(thisThread.beats * 2pi /8)}));
)

(
Pdefn(\pb2Dur, 1/4).quant_(4);
Pdefn(\pb2Rel, 0.08).quant_(4);
Pdefn(\pb2Pan, rrand(-0.01, 0.01 ));
)

Pdefn(\pb1Dur, 1/4).quant_(4);
Pdefn(\pb1Dur, 1/8).quant_(4);
Pdefn(\pb1Dur, 1/12).quant_(4);
Pdefn(\pb1StartPos, rrand(0, ~sample1.numFrames - 1)).quant_(4);

