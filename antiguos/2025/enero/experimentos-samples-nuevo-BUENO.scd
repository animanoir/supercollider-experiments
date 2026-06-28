s.options.sampleRate = 48000;
s.boot;

// (
// ~teAmoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/";
// ~tePath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/te/";
// ~amoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/amo/";
//
// ~te1 = Buffer.read(s, ~tePath++"te1.wav");
// ~te2 = Buffer.read(s, ~tePath++"te2.wav");
// ~te3 = Buffer.read(s, ~tePath++"te3.wav");
//
// ~amo1 = Buffer.read(s, ~amoPath++"amo1.wav");
// ~amo2 = Buffer.read(s, ~amoPath++"amo2.wav");
// ~amo3 = Buffer.read(s, ~amoPath++"amo3.wav");
// )


// satie ------------------------------------------------------------------------------

~mainPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
~satie = Buffer.read(s, ~mainPath++"/samples/satie2.wav");
~gas = Buffer.read(s, ~mainPath++"/samples/huerco1.wav");
~voz = Buffer.read(s, ~mainPath++"/samples/voz.wav");
~voz2 = Buffer.read(s, ~mainPath++"/samples/voz-2.wav");
~at1 = Buffer.read(s, ~mainPath++"/samples/at.wav");
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
	var sig, pan, env, revFx;
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.02), \rel.ir(1.0)],
		curve: \sine
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(
		1,
		~at1.bufnum,
		rate,
		//trigger: Impulse.kr(LFNoise2.kr(10.0).range(1, 15))*env,
		startPos: LFNoise2.kr(1.0).range(0, BufFrames.kr(~at1)-1),
		loop: 1);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	//revFx = FreeVerb.ar(pan, 1.0, 0.8, 1.0);
	Out.ar(out, pan);
}).add;
)

(
SynthDef(\voz, {
	arg buf =0, rate = 1, out = 0, reset_pos = 0, t_trig = 1, start_pos = 0;
	var sig, pan, env, modAmp, delayFx;
	modAmp = LFNoise2.kr(1.0).range(0.0,1.0);
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
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 20))*env,
		startPos: LFNoise2.kr(1.0).range(0, BufFrames.ir(~voz2)-1),
		loop: 0);
	sig = RLPF.ar(
		in: sig,
		freq: LFNoise2.kr(1.0).range(100, 10000),
		rq: LFNoise2.kr(1.0).range(0.001, 0.8)
	);
	delayFx = DelayN.ar(sig, LFNoise0.kr(1.0).range(0.1,5.0));
	pan = Pan2.ar(sig + delayFx, LFNoise2.kr(5.0).range(-1.0, 1.0));
	Out.ar(out, pan * modAmp);
}).add;
)


// kik ----------------------------------------------------------------
~kik1Path = PathName.new(thisProcess.nowExecutingPath).parentPath;
~kik1 = Buffer.read(s, ~kik1Path++"/samples/BD_Plastiklog.wav");

(
SynthDef.new(\kik1, {
	var sig, pan;
	sig = PlayBuf.ar(
		1,
		~kik1.bufnum,
		trigger: Impulse.kr(LFNoise0.kr(0.1))
	);
	Out.ar(0, sig!2);
}).add
)

// hihat
~hh1 = Buffer.read(s, ~mainPath++"/samples/hh1.wav");
~hh2 = Buffer.read(s, ~mainPath++"/samples/hh2.wav");
(
SynthDef(\hh1, {
	arg buf =0, rate = 1, out = 0, reset_pos = 0, t_trig = 1, start_pos = 0;
	var sig, pan, env, modAmp;
	modAmp = LFNoise2.kr(5.0).range(0.0,1.0);
	env = Env(
		levels: [0, 1, 0],
		times: [\atk.ir(0.02), \rel.ir(1.0)],
		curve: \sine
	).ar(2);
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(
		1,
		~hh2.bufnum,
		rate,
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 50))*env,
		loop: 0);
	sig = LPF.ar(
		in: sig,
		freq: LFNoise2.kr(1.0).range(100, 10000)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(out, pan * (modAmp * 0.5));
}).add;
)

(
x = Routine({
	inf.do({
		//Synth(\satie, [buf: ~satie.bufnum, rate: -2.0.midiratio]);
		Synth(\gas1, [buf: ~gas.bufnum, rate: 0.8]);
		Synth(\gas1, [buf: ~gas.bufnum, rate: 0.2]);
		//Synth(\kik1, [buf: ~kik1.bufnum]);
		Synth(\voz, [buf: ~voz2.bufnum, rate: -1.0, start_pos: rrand(0, ~voz2.numFrames - 1)]);
		Synth(\hh1, [buf: ~hh2.bufnum, rate: 1.0, start_pos: rrand(0, ~hh2.numFrames - 1)]);
		10.0.wait;
	});
}).play
);
x.stop;

// satie ------------------------------------------------------------------------------

TempoClock.default.tempo;

t = TempoClock.new(130/60);
t.beats;
