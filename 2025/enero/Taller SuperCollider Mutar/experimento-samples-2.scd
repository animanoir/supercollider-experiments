

(
~teAmoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/";
~tePath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/te/";
~amoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/amo/";

~te1 = Buffer.read(s, ~tePath++"te1.wav");
~te2 = Buffer.read(s, ~tePath++"te2.wav");
~te3 = Buffer.read(s, ~tePath++"te3.wav");

~amo1 = Buffer.read(s, ~amoPath++"amo1.wav");
~amo2 = Buffer.read(s, ~amoPath++"amo2.wav");
~amo3 = Buffer.read(s, ~amoPath++"amo3.wav");
)

// Te's
// te1
(
SynthDef.new(\te1, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~te1.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~te1Buf;
~te1Buf=Synth(\te1);
~te1Buf.set(\rate, 0.5);
~te1Buf.free;


// te2
(
SynthDef.new(\te2, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~te2.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~te2Buf;
~te2Buf=Synth(\te2);
~te2Buf.free;

// te3
(
	SynthDef.new(\te3, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~te3.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
	}).add
)
~te3Buf;
~te3Buf=Synth(\te3);
~te3Buf.free;

// Amo's
// amo1

(
SynthDef(\amo1, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~amo1.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add
);
~amo1Buf;
~amo1Buf = Synth(\amo1);

// amo2
(
SynthDef(\amo2, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~amo2.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~amo2Buf;
~amo2Buf = Synth(\amo2);


// amo3
(
{
	var sig;
	sig = PlayBuf.ar(2,~amo3.bufnum,loop:1);
	sig = sig * 1.0;
}.play;
)