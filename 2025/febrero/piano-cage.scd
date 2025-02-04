s.options.sampleRate = 48000;
s.boot;
s.quit;

~mainPath = PathName.new(thisProcess.nowExecutingPath).parentPath;

~c1 = Buffer.read(s, ~mainPath++"/samples/c1.wav");
~c2 = Buffer.read(s, ~mainPath++"/samples/c2.wav");
~c3 = Buffer.read(s, ~mainPath++"/samples/c3.wav");
~c4 = Buffer.read(s, ~mainPath++"/samples/c4.wav");
~c5 = Buffer.read(s, ~mainPath++"/samples/c5.wav");

(
SynthDef(\cNote, {
	var sig, modAmp, pan, amp, trigger, buf = \buf.ir(0);
	//trigger = Impulse.kr(Rand.new(0.1, 5.0));
	//amp = EnvGen.kr( Env.perc, trigger);
	//modAmp = SinOsc.kr(Rand.new(0.1, 1.0)).range(0.0,0.9);
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
	Out.ar(0, pan);
}).add;
)

(
~rCages = r{
	loop{
		s.bind{
			Synth(\cNote, [buf: ~c1.bufnum]);
			0.25.wait;
			Synth(\cNote, [buf: ~c2.bufnum]);
			0.25.wait;
		};
		1.wait;
	}
}.play;
)

~rBudds.play;