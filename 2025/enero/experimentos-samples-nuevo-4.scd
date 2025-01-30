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
~te1Buf.free;







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






// kik ----------------------------------------------------------------
~kik1Path = PathName.new(thisProcess.nowExecutingPath).parentPath;
~kik1 = Buffer.read(s, ~kik1Path++"/samples/BD_Plastiklog.wav");

(
SynthDef.new(\kik1, {
	var sig, pan;
	sig = PlayBuf.ar(
		1,
		~kik1.bufnum,
		rate: speed,
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 100)),
		startPos: LFNoise2.kr(1.0).range(0, BufFrames.kr(~kik1)-1)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(10).range(-1.0,1.0));
	Out.ar(0, pan);
}).add
)

// satie ------------------------------------------------------------------------------

~mainPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
~satie = Buffer.read(s, ~mainPath++"/samples/satie2.wav");
~gas = Buffer.read(s, ~mainPath++"/samples/huerco1.wav");
~voz = Buffer.read(s, ~mainPath++"/samples/voz.wav");
~voz2 = Buffer.read(s, ~mainPath++"/samples/voz-2.wav");
~satie.numFrames;
~voz.numFrames;

(
SynthDef(\satie, {
	arg buf =0, rate = 1, out = 0, reset_pos = 0, t_trig = 1, start_pos = 0;
	var sig, pan, env;
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.02), \rel.ir(1.0)],
		curve: \sine
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(
		1,
		~satie.bufnum,
		rate,
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 20)),
		startPos: LFNoise2.kr(1.0).range(0, BufFrames.kr(~satie)-1),
		//startPos: SinOsc.ar(1.0).range(0, BufFrames.ir(~satie)),
		loop: 0);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(out, pan);
}).add;
)

(
SynthDef(\gas1, {
	arg buf =0, rate = 2, out = 0, reset_pos = 0, t_trig = 1;
	var sig, pan, env;
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.02), \rel.ir(1.0)],
		curve: \sine
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(
		1,
		~gas.bufnum,
		rate,
		//trigger: Impulse.kr(LFNoise2.kr(10.0).range(1, 15))*env,
		//startPos: LFNoise2.kr(1.0).range(0, BufFrames.kr(~gas)-1),
		//startPos: LFNoise2.kr(1.0).range(0, BufFrames.ir(~gas)-1),
		loop: 1);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(out, pan);
}).add;
)

(
SynthDef(\voz, {
	arg buf =0, rate = 1, out = 0, reset_pos = 0, t_trig = 1, start_pos = 0;
	var sig, pan, env, modAmp;
	modAmp = LFNoise2.kr(1.0).range(0.0,1.5);
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.02), \rel.ir(1.0)],
		curve: \sine
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(
		1,
		~voz2.bufnum,
		rate,
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 50))*env,
		startPos: LFNoise2.kr(1.0).range(0, BufFrames.ir(~voz2)-1),
		loop: 0);
	sig = RLPF.ar(
		in: sig,
		freq: LFNoise2.kr(2.0).range(100, 6000),
		rq: LFNoise2.kr(2.0).range(0.01,0.9);
	);
	pan = Pan2.ar(sig, LFNoise2.kr(1.0).range(-1.0, 1.0));
	Out.ar(out, pan * modAmp);
}).add;
)
(
x = Routine({
	inf.do({
		//Synth(\satie, [buf: ~satie.bufnum, rate: -2.0.midiratio]);
		Synth(\gas1, [buf: ~gas.bufnum, rate: 0.8]);
		//Synth(\kik1, [buf: ~kik1.bufnum, rate: 1.0.midiratio]);
		Synth(\voz, [buf: ~voz2.bufnum, rate: 1.0, start_pos: rrand(0, ~satie.numFrames - 1), trighz: exprand(0.5, 5)]);
		1.0.wait;
	});
}).play
);
x.stop;

// satie ------------------------------------------------------------------------------

TempoClock.default.tempo;

t = TempoClock.new(130/60);
t.beats;
