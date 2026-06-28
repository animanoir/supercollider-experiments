s.options.sampleRate = 48000;
s.boot;
s.restart;


~mainPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(
~tam1 = Buffer.read(s, ~mainPath++"/samples/tamborcito-1.wav");
~tam2 = Buffer.read(s, ~mainPath++"/samples/tamborcito-2.wav");
~tam3 = Buffer.read(s, ~mainPath++"/samples/tamborcito-3.wav");
~tam4 = Buffer.read(s, ~mainPath++"/samples/tamborcito-4.wav");
~tam5 = Buffer.read(s, ~mainPath++"/samples/tamborcito-5.wav");
~tam6 = Buffer.read(s, ~mainPath++"/samples/tamborcito-6.wav");
~tam7 = Buffer.read(s, ~mainPath++"/samples/tamborcito-7.wav");
~tam8 = Buffer.read(s, ~mainPath++"/samples/tamborcito-8.wav");
)

~voz = Buffer.read(s, ~mainPath++"samples/voz.wav");
~voz2 = Buffer.read(s, ~mainPath++"/samples/voz2.wav");

~at = Buffer.read(s, ~mainPath++"/samples/at.wav");
~gas = Buffer.read(s, ~mainPath++"/samples/huerco1.wav");

~ay = Buffer.read(s, ~mainPath++"/samples/coro.wav");



// pads

(
SynthDef(\budd, {
	var sig, modAmp, pan, amp, trigger, buf = \buf.ir(0);
	//trigger = Impulse.kr(Rand.new(0.1, 5.0));
	//amp = EnvGen.kr( Env.perc, trigger);
	modAmp = SinOsc.kr(Rand.new(0.1, 1.0)).range(0.0,0.9);
	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 1)),
		//startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1),
		//rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-2, 0)}.dup(2).midiratio)
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * \nrate.ir.midiratio)
	);
	sig = Mix.ar(sig.sum);
	pan = Pan2.ar(sig, LFNoise2.kr(Rand.new(0.1, 10.0)).range(-1.0, 1.0));
	Out.ar(0, pan * modAmp);
}).add;
)


(
SynthDef(\gas, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(SinOsc.ar(10.0).range(0, 10)).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 5)),
		startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1),
		//rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-12, 0)}.dup(2).midiratio)
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * \nrate.ir.midiratio)
		//rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-1, 1)}.dup(2).midiratio),
	);
	sig = Mix.ar(sig.sum);
	pan = Pan2.ar(sig, LFNoise2.kr(Rand.new(0.1, 10.0)).range(-1.0, 1.0))*(modAmp);
	Out.ar(0, pan);
}).add;
)

(
SynthDef(\ay, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(Rand.new(0.1, 1.0)).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 5)),
		startPos: LFNoise2.kr(5.0).range(0, BufFrames.ir(\buf.ir)-1),
		//rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-12, 0)}.dup(2).midiratio)
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * \nrate.ir.midiratio)
	);
	sig = Mix.ar(sig.sum);
	pan = Pan2.ar(sig, LFNoise2.kr(Rand.new(0.1, 1.0)).range(-1.0, 1.0))*(modAmp);
	Out.ar(0, pan);
}).add;
)

// tamborcitos
(
SynthDef(\tam, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(Rand.new(0.1, 10.0)).range(0.1,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 1)),
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(12, 0)}.dup(2).midiratio)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(5.0).range(-1.0, 1.0));
	Out.ar(0, pan * (modAmp));
}).add;
)

// voz

(
SynthDef(\voz, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = LFNoise2.kr(10.0).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(SinOsc.ar(1.0).range(1.0, 5.0)).range(1, 30)),
		startPos: LFNoise0.kr(SinOsc.ar(1.0).range(1.0, 5.0)).range(0, BufFrames.ir(\buf.ir)-1),
		loop: 1,
		//startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(SinOsc.ar(1.0).range(1.0, 5.0)).range(-1.0, 1.0));
	Out.ar(0, pan);
}).add;
)

(
SynthDef(\vozP, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = LFNoise2.kr(10.0).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(SinOsc.ar(\oscspeed.ir).range(1.0, 5.0)).range(1, 30)),
		startPos: LFNoise0.kr(SinOsc.ar(\oscspeed.ir).range(1.0, 5.0)).range(0, BufFrames.ir(\buf.ir)-1),
		loop: 1,
		rate: \rate.ir
		//startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1)
	);
	//pan = Pan2.ar(sig, LFNoise2.kr(SinOsc.ar(1.0).range(1.0, 5.0)).range(-1.0, 1.0));
	Out.ar(\pbus.ir, sig);
}).add;
)

(
~routine1 = r{
	loop{
		s.bind {
			//Synth(\gas, [buf: ~gas.bufnum, \nrate: -12.0]);
			Synth(\gas, [buf: ~voz.bufnum, \nrate: 1.0]);
			Synth(\vozP, [buf: ~voz.bufnum, rate: 1.0, \pbus: 0, \oscpseed: 50.0]);
			Synth(\vozP, [buf: ~voz.bufnum, rate: -1.0, \pbus: 1, \oscpseed: 40.0]);
		};
		1000.wait;
	}
}.play;
)
~routine1.play;

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
		loop: 1);
	sig = LPF.ar(
		in: sig,
		freq: LFNoise2.kr(1.0).range(100, 10000)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(out, pan * (modAmp * 0.5));
}).add;
)

~mainTempo = TempoClock.new();

~budd1 = Buffer.read(s, ~mainPath++"/samples/budd-1.wav");
~budd2 = Buffer.read(s, ~mainPath++"/samples/budd-2.wav");
~budd3 = Buffer.read(s, ~mainPath++"/samples/budd-3.wav");
~budd4 = Buffer.read(s, ~mainPath++"/samples/budd-4.wav");
~budd5 = Buffer.read(s, ~mainPath++"/samples/budd-5.wav");
~budd6 = Buffer.read(s, ~mainPath++"/samples/budd-6.wav");

(
~rBudds = r{
	loop{
		s.bind{
			Synth(\budd, [buf: ~budd1.bufnum]);
			Synth(\budd, [buf: ~budd2.bufnum]);
			Synth(\budd, [buf: ~budd3.bufnum]);
			Synth(\budd, [buf: ~budd4.bufnum]);
			Synth(\budd, [buf: ~budd5.bufnum]);
			Synth(\budd, [buf: ~budd6.bufnum]);
		};
	}
}.play;
)

~rBudds.play;
// -----------------------------------------------
(
~rBudds2 = Routine.new({
	Synth(\budd, [buf: ~budd1.bufnum]);
	1.0.wait;
	Synth(\budd, [buf: ~budd2.bufnum]);
	1.0.wait;
	Synth(\budd, [buf: ~budd3.bufnum]);
	2.0.wait;
	Synth(\budd, [buf: ~budd4.bufnum]);
	0.25.wait;
	Synth(\budd, [buf: ~budd5.bufnum]);
	1.5.wait;
	Synth(\budd, [buf: ~budd6.bufnum]);
});
)

~rBudds2.play;
~rBudds2.stop;



