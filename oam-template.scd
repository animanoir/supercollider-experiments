s.boot;
s.plotTree;
s.freeAll;

ClassBrowser.new()
t = TempoClock(130/60).permanent_(true);

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
  |startPos = 0, rel = 0.08, buf|
  var sig, env;
  env = EnvGen.kr(Env.perc(0.001, rel), doneAction: 2);
  sig = PlayBuf.ar(2, buf, startPos: startPos, loop: 0, doneAction: 2);
  sig = sig * env;
  Out.ar(0, sig)
}).add;
)

(
Synth(\glitchBuf, [
  \buf, ~sample1, 
  \startPos: rrand(0, ~sample1.numFrames - 1),
  \rel: rrand(0.08, 0.5)
]);
)

(
var randStartPos = Pwhite(0,~sample1.numFrames - 1);
~pb1 = Pbind(
  \instrument, \glitchBuf,
  \buf, ~sample1,
  \dur, 1/8,
  \startPos, randStartPos,
  \rel, SinOsc.ar(0.5).range(0.1, 1.0)
);
)

~pb1.play(t, quant: 2);

