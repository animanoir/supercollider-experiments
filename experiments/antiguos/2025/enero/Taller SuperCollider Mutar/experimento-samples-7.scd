s.options.sampleRate = 48000;
s.boot;

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
~kik1Path = PathName.new(thisProcess.nowExecutingPath).parentPath;
~kik1 = Buffer.read(s, ~kik1Path++"/samples/BD_Plastiklog.wav");



// Te's
// te1
(
SynthDef.new(\te1, {
	arg rate=1.0, start_pos=1000, tTrig=1;
	var sig, pan;
	sig = PlayBuf.ar(2,~te1.bufnum, loop:0, rate: rate, startPos: 5000.0, trigger:tTrig );
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~te1Buf;
~te1Buf=Synth(\te1, [\start_pos, rrand(0,10000)]);
~te1Buf.set(\rate, 0.5);
~te1Buf.set([\tTrig, 1])

//Para activarlo a través de un trigger, reproducirá desde la posición de comienzo startPos (recuerden cambiar doneAction a 0)
x = Synth(\player, [\buf, b.bufnum, \doneaction, 0, \rate, 0.75]);
x.set(\t_trig, 1)


(
SynthDef.new(\kik1, {
	var sig, pan, speed=1.0;
	sig = PlayBuf.ar(1,~kik1.bufnum, rate: speed);
	pan = Pan2.ar(sig, LFNoise2.kr(10).range(-1.0,1.0));
	Out.ar(0, pan);
}).add
)




~te1Buf.free;

(
SynthDef.new(\te1Bufrd,{
	arg buf=0, out=0;
	var sig, phs;
	phs=Line.ar(0,BufFrames.kr(buf)-1, BufDur.kr(buf), doneAction:2);
	sig=BufRd.ar(1,buf,phs);
	Out.ar(out, sig!2);
}).add;
)

// te2
(
SynthDef.new(\te2, {
	arg rate=1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~te2.bufnum, loop:0, rate: rate);
	sig = HPF.ar(sig, SinOsc.ar(1).range(100,800));
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~te2Buf;
~te2Buf=Synth(\te2);
~te2Buf.free;


(
r = Routine({
	var rate;
	var arr1 = [-1.0, 1.0];
	var arr1Index = 0;
	inf.do({
		rate = arr1[arr1Index];
		arr1Index = (arr1Index + 1) % arr1.size;
		Synth(\te2, [\doneaction, 0, \rate, rate]);
		Synth(\kik1, [\doneaction, 0, \speed, rate]);
		0.2.yield
	})
}).play
);
r.stop;



// te3
(
	SynthDef.new(\te3, {
	arg rate= -1.0;
	var sig, pan;
	sig = PlayBuf.ar(2,~te3.bufnum, loop:1, rate: rate);
	pan = Pan2.ar(sig.sum, LFNoise2.kr(5).range(-1.0,1.0));
	Out.ar(0, pan);
	}).add
)
~te3Buf;
~te3Buf=Synth(\te3);
~te3Buf.free;



// satie ------------------------------------------------------------------------------

~satie = PathName.new(thisProcess.nowExecutingPath).parentPath;
~satie = Buffer.read(s, ~satie++"/samples/satie.wav");
~satie.numFrames;
(
SynthDef(\satie, {
	arg buf =0, rate = 1, out = 0, reset_pos = 0, t_trig = 1, start_pos = 0;
	var sig, pan, env;
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.0001), \rel.ir(0.5)],
		curve: [0, -4]
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(1, ~satie.bufnum, rate, Impulse.kr(\trighz.kr(6)), startPos: start_pos);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(out, pan);
}).add;
)

(
x = Routine({
	var rate;
	inf.do({
		Synth(\satie, [buf: ~satie.bufnum, rate: 1.0, start_pos: rrand(0, ~satie.numFrames - 1)]);
		0.5.wait;
	})
}).play
);

x.stop;

// satie ------------------------------------------------------------------------------



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
~amo1Buf.free;

// amo2
(
SynthDef(\amo2, {
	arg rate=1.0;
	var sig, pan, modAmp;
	sig = PlayBuf.ar(2,~amo2.bufnum, loop:1, rate: rate);
	sig = sig * LFDNoise0.kr(20).range(0.0,1.0);
	pan = Pan2.ar(sig.sum, LFNoise0.kr(20).range(-1.0,1.0));
	Out.ar(0, pan);
}).add;
)
~amo2Buf;
~amo2Buf = Synth(\amo2);
~amo2Buf.free;
// ¿Cómo liberar los Synths que se acumularon al enviarlos al servidor?


// amo3
(
{
	var sig;
	sig = PlayBuf.ar(2,~amo3.bufnum,loop:1);
	sig = sig * 1.0;
}.play;
)