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

// tamborcitos
(
SynthDef(\tam, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(Rand.new(0.1, 10.0)).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 0.5)),
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(12, 0)}.dup(2).midiratio)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(5.0).range(-1.0, 1.0));
	Out.ar(0, pan * (modAmp * 0.5));
}).add;
)

// voz

(
SynthDef(\voz, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = LFNoise2.kr(1.0).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		trigger: Impulse.kr(LFNoise2.kr(SinOsc.kr(10.0)).range(0, 1.0)),
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(1, 0)}.dup(3).midiratio),
		loop: 1,
		startPos: LFNoise2.kr(10.0).range(0, BufFrames.ir(\buf.ir)-1)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(10.0).range(-1.0, 1.0));
	Out.ar(0, pan);
}).add;
)

(
~routine1 = Routine({

	Synth(\tam, [buf: ~tam1.bufnum]);
	Synth(\tam, [buf: ~tam2.bufnum]);
	//Synth(\tam, [buf: ~tam3.bufnum]);
	Synth(\tam, [buf: ~tam4.bufnum]);
	//Synth(\tam, [buf: ~tam5.bufnum]);
	//Synth(\tam, [buf: ~tam6.bufnum]);
	//Synth(\tam, [buf: ~tam7.bufnum]);
	Synth(\tam, [buf: ~tam8.bufnum]);
	Synth(\voz, [buf: ~voz.bufnum]);

	5.wait;
}).play;
)

(
~routine2 = Routine({



	Synth(\tam, [buf: ~tam5.bufnum]);
	Synth(\tam, [buf: ~tam7.bufnum]);


	1.wait;
}).play;
)

(
~routine4 = Routine({

	Synth(\tam, [buf: ~tam1.bufnum]);
	Synth(\tam, [buf: ~tam2.bufnum]);

	1.wait;
}).play;
)

~routine1.release(3);
