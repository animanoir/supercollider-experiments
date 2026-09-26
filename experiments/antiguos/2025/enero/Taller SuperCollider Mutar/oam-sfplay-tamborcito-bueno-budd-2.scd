s.options.sampleRate = 48000;
s.boot;

~mainPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
~tam1 = Buffer.read(s, ~mainPath++"/samples/tamborcito-1.wav");
~tam2 = Buffer.read(s, ~mainPath++"/samples/tamborcito-2.wav");
~tam3 = Buffer.read(s, ~mainPath++"/samples/tamborcito-3.wav");
~tam4 = Buffer.read(s, ~mainPath++"/samples/tamborcito-4.wav");
~tam5 = Buffer.read(s, ~mainPath++"/samples/tamborcito-5.wav");
~tam6 = Buffer.read(s, ~mainPath++"/samples/tamborcito-6.wav");
~tam7 = Buffer.read(s, ~mainPath++"/samples/tamborcito-7.wav");
~tam8 = Buffer.read(s, ~mainPath++"/samples/tamborcito-8.wav");

~voz = Buffer.read(s, ~mainPath++"/samples/voz.wav");

~gas = Buffer.read(s, ~mainPath++"/samples/at.wav");

~ay = Buffer.read(s, ~mainPath++"/samples/coro.wav");

~budd1 = Buffer.read(s, ~mainPath++"/samples/budd-1.wav");
~budd2 = Buffer.read(s, ~mainPath++"/samples/budd-2.wav");
~budd3 = Buffer.read(s, ~mainPath++"/samples/budd-3.wav");
~budd4 = Buffer.read(s, ~mainPath++"/samples/budd-4.wav");
~budd5 = Buffer.read(s, ~mainPath++"/samples/budd-5.wav");
~budd6 = Buffer.read(s, ~mainPath++"/samples/budd-6.wav");


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
	modAmp = SinOsc.kr(Rand.new(0.1, 1.0)).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 5)),
		startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1),
		//rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-12, 0)}.dup(2).midiratio)
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * \nrate.ir.midiratio)
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
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 10)),
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
	modAmp = LFNoise2.kr(5.0).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 20)),
		startPos: LFNoise0.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1),
		loop: 1,
		//startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(10.0).range(-1.0, 1.0));
	Out.ar(0, pan);
}).add;
)

(
~routine1 = Routine({

	Synth(\tam, [buf: ~tam1.bufnum]);
	Synth(\tam, [buf: ~tam2.bufnum]);
	//Synth(\gas, [buf: ~gas.bufnum]);
	Synth(\voz, [buf: ~voz.bufnum, rate: 1.0]);

	5.wait;
}).play;
)

~routine1.stop;

(
~routine2 = Routine({
	Synth(\voz, [buf: ~voz.bufnum, rate: 1.0]);
	1.wait;
}).play;
)

~routine2.stop;

(
~routine3 = Routine({

	Synth(\budd, [buf: ~budd1.bufnum, \nrate: -12.0]);
	Synth(\budd, [buf: ~budd2.bufnum, \nrate: 12.0]);
	Synth(\budd, [buf: ~budd3.bufnum, \nrate: -5]);
	Synth(\budd, [buf: ~budd4.bufnum]);
	Synth(\budd, [buf: ~budd5.bufnum]);
	Synth(\budd, [buf: ~budd6.bufnum]);

	5.wait;
}).play;
)

~routine1.release(3);
