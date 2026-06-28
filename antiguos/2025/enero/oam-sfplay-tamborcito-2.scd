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

(
SynthDef(\tam, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(5.0).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
        trigger: Impulse.kr(LFNoise2.kr(0.1).range(0, 0.5)),
		rate: (BufRateScale.ir(buf) * \rate.ir(1) * {Rand(-24, 0)}.dup(2).midiratio)
	);
	pan = Pan2.ar(sig, LFNoise2.kr(5.0).range(-1.0, 1.0));
	Out.ar(0, pan * (modAmp * 0.5));
}).add;
)

(
~routine1 = Routine({

		Synth(\tam, [buf: ~tam1.bufnum]);

		10.wait;
}).play;
)

~routine1.play;
