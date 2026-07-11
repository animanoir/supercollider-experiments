// Companion Code 6.4
// Real-Time Granular Synthesis

// GrainIn provides a simple option for granulating a live signal. By itself, it doesn't offer many creative options. As discussed in the book, one enhancement involves delaying the input signal before granulation takes place, offsetting the temporal position of the grains and providing more irregularity. Here, in addition, we also include a gated amplitude envelope for fading the effect in and out, a pre-granulation low-pass filter for optional spectral coloration, and the stereo pan position of each grain is randomly chosen from a range. The code has also been divided into two separate SynthDefs.

(
s.options.memSize_(2.pow(20));
s.reboot;
)

(
s.newBusAllocators;
~micbus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 1, auxamp = 0;
	var sig = SoundIn.ar(in);
	Out.ar(out, sig ! 2 * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\grain, {
	arg in = 0, gate = 1, atk = 0.01, rel = 3, cf = 20000,
	del = 0.25, dens = 30, graindur = 0.07, pan = 0, amp = 1, out = 0;
	var sig, env, panctrl;
	sig = In.ar(in, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);
	panctrl = LFNoise1.kr(20).bipolar(pan);
	sig = LPF.ar(sig, cf);
	sig = DelayN.ar(sig, del, del);
	sig = GrainIn.ar(2, Dust.kr(dens), graindur, sig, panctrl);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
// FEEDBACK WARNING — use headphones

~mic = Synth(\mic, [auxout: ~micbus, auxamp: 0.7]);
~grain = Synth(\grain, [
	in: ~micbus,
	atk: 3,
	rel: 5,
	cf: 5000,
	del: 0.25,
	pan: 0.7,
], ~mic, \addAfter);
)

~grain.set(\gate, 0);

~mic.free;

// The sound is more intricate when several unique granulators operate on the same signal. In the following code, we create ten granulators, whose parameters vary based on the iteration count. The number of granulators is declared as a variable to facilitate changing this quantity before evaluating. As the iteration count increases, each successive granulator is quieter, more heavily filtered and widely panned, producing shorter, denser grains with longer delay times. The result is a complex grain trail that dissipates over time.

(
// FEEDBACK WARNING — use headphones

var num = 10;
~mic = Synth(\mic, [auxout: ~micbus, auxamp: 0.7]);
~grain = num.collect({ |n|
	Synth(\grain, [
		in: ~micbus,
		atk: exprand(2, 3),
		amp: n.linlin(0, num-1, -3, -15).dbamp,
		cf: n.linexp(0, num-1, 20000, 2000),
		del: n.linexp(0, num-1, 0.08, 1.5),
		dens: n.linexp(0, num-1, 8, 60),
		graindur: n.linexp(0, num-1, 0.3, 0.03),
		pan: n.linexp(0, num-1, 0.1, 0.7)
	], ~mic, \addAfter);
});
)

~grain.do({ |n| n.set(\gate, 0) }); // fade granulators

~mic.free;

// By swapping DelayN for an interpolating feedback delay (CombL), the granular trail is intensified and elongated. In the following code, we also randomly modulate the delay time, which introduces subtle pitch variations into the delayed signal.

(
s.newBusAllocators;
~micbus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 1, auxamp = 0;
	var sig = SoundIn.ar(in);
	Out.ar(out, sig ! 2 * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\grain, {
	arg in = 0, gate = 1, atk = 0.01, rel = 3, cf = 20000, echoes = 12,
	del = 0.25, dens = 30, graindur = 0.07, pan = 0, amp = 1, out = 0;
	var sig, env, panctrl, delmod;
	sig = In.ar(in, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);
	panctrl = LFNoise1.kr(20).bipolar(pan);
	delmod = LFNoise1.kr(ExpRand(0.08, 0.15)).exprange(0.5,1);
	sig = LPF.ar(sig, cf);
	sig = CombL.ar(sig, del, del*delmod, del*echoes);
	sig = GrainIn.ar(2, Dust.kr(dens), graindur, sig, panctrl);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
// FEEDBACK WARNING — use headphones

var num = 10;
~micGrp = Group();
~grainGrp = Group(~micGrp, \addAfter);

~mic = Synth(\mic, [
	auxout: ~micbus,
	auxamp: 0.7,
], ~micGrp);

~grain = num.collect({ |n|
	Synth(\grain, [
		in: ~micbus,
		atk: exprand(2, 3),
		amp: n.linlin(0, num-1, -3, -15).dbamp,
		cf: n.linexp(0, num-1, 20000, 2000),
		del: n.linexp(0, num-1, 0.08, 1.5),
		dens: n.linexp(0, num-1, 8, 60),
		graindur: n.linexp(0, num-1, 0.3, 0.03),
		pan: n.linlin(0, num-1, 0.1, 0.7),
		out: 0
	], ~grainGrp);
});
)

~grain.do({ |n| n.set(\gate, 0, \rel, 8) });

~mic.free;

// Experimentation with additional variations is left as an exercise to the reader. Such experimentation might involve replacing Dust with Impulse to produce rhythmic grain streams, or tinkering with the value mapping scheme within the iteration block.

// Efficiency is a concern with this approach. To create complex grain clusters, we must instantiate multiple Synths, each containing its own delay line with a potentially long delay time. When using DelayN, CombL, etc., we risk of memory allocation failures (hence the 'memSize' increase at the top of this file). Alternatively, we could use BufDelayN, BufCombL, etc., but this approach requires manual allocation of individual buffers for each delay unit, which can be tedious.

// GrainBuf invites a more attractive approach with a wider array of creative options, at the low cost of a slightly more complex setup involving a buffer and four SynthDefs: a microphone input signal, a frame pointer used as a buffer index, a buffer-recording process, and a buffer granulator. The recorder and granulator use the same frame pointer, but the granulator subtracts some amount so that the grain pointer remains behind the record pointer. The length of our buffer is 5 seconds, but this is flexible. Shorter is fine, but extremely short buffers will restrict grain size. Longer buffers (within reason) are not problematic, and may even be necessary depending on how much audio we want to retain.

// In the book, our GrainBuf SynthDef prioritized the pointer delay at the cost of grain duration; as the pointer delay decreased, the grains became smaller to accommodate. Here, for the sake of illustration, we do the opposite: the amount of space needed to create a grain influences the space between the playback and recording pointers. As grain size or grain playback rate increases, more space is needed, so the grain pointer is pushed backward to accommodate.

(
Buffer.freeAll;
b = Buffer.alloc(s, s.sampleRate * 5);

s.newBusAllocators;
~micbus = Bus.audio(s, 1);
~ptrbus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 1, auxamp = 0;
	var sig = SoundIn.ar(in);
	Out.ar(out, sig ! 2 * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\ptr, {
	arg out = 0, buf = 0;
	var sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef(\rec, {
	arg ptrin = 0, in = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrin, 1);
	sig = In.ar(in, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef(\grain, {
	arg ptrin = 0, gate = 1, atk = 0.01, rel = 3, buf = 0, pan = 0, amp = 1,
	dens = 30, rate = 1, ptrdelay = 0.25, graindur = 0.07, out = 0;
	var sig, ptr, env;

	ptr = In.ar(ptrin, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);

	// The grain pointer delay cannot be smaller than
	// the duration needed for grain creation:
	ptrdelay = max(ptrdelay, graindur * rate);

	ptr = ptr - (ptrdelay * SampleRate.ir) / BufFrames.kr(buf);

	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: Dust.kr(dens),
		dur: graindur,
		sndbuf: buf,
		rate: rate,
		pos: ptr,
		interp: 2,
		pan: LFNoise1.kr(20).bipolar(pan)
	);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
// FEEDBACK WARNING — use headphones

b.zero;

~srcGrp = Group();
~recGrp = Group(~srcGrp, \addAfter);
~grainGrp = Group(~recGrp, \addAfter);

~mic = Synth(\mic, [
	auxout: ~micbus,
	auxamp: 0.7
], ~srcGrp);

~ptr = Synth(\ptr, [
	buf: b,
	out: ~ptrbus
], ~srcGrp);

~rec = Synth(\rec, [
	ptrin: ~ptrbus,
	in: ~micbus,
	buf: b
], ~recGrp);

~grain = Synth(\grain, [
	ptrin: ~ptrbus,
	buf: b,
	ptrdelay: 1/3,
	dens: 40,
	graindur: 0.06,
	pan: 0.5,
	out: 0
], ~grainGrp);
)

~grain.set(\gate, 0, \rel, 5);

s.freeAll;

// In the example above, the pointer delay is constant, and the simple echo flavor is audible despite the application of grain envelopes. Overall, this result is similar to early GrainIn examples. With GrainBuf, however, we have the ability to introduce randomness into the grain pointer, causing it to skitter around and jumble the audio.

// With a randomly changing grain pointer position, it is even more important to ensure that it remains sufficiently behind the record pointer, to avoid clicks. After creating a noise generator for the random offset, we make a slight modification to the previous \grain SynthDef to ensure enough space for grain creation.

// Note that this approach does not prevent encountering the buffer discontinuity from the other direction, i.e. from "in front" of the discontinuity. This might happen if the value of the pointer delay and/or random pointer deviation were excessively large. We could apply another constraint operation, but a simpler solution is to choose sensible values for these parameters, i.e., values which are well within the total duration of the buffer (an alternative solution is to allocate an even longer buffer).

(
Buffer.freeAll;
b = Buffer.alloc(s, s.sampleRate * 5);

s.newBusAllocators;
~micbus = Bus.audio(s, 1);
~ptrbus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 1, auxamp = 0;
	var sig = SoundIn.ar(in);
	Out.ar(out, sig ! 2 * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\ptr, {
	arg out = 0, buf = 0;
	var sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef(\rec, {
	arg ptrin = 0, in = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrin, 1);
	sig = In.ar(in, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef(\grain, {
	arg ptrin = 0, gate = 1, atk = 0.01, rel = 3, buf = 0, pan = 0, amp = 1,
	dens = 30, rate = 1, ptrdelay = 0.25, ptrdev = 0.15, graindur = 0.07, out = 0;
	var sig, env, ptr, ptrrand;

	ptr = In.ar(ptrin, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);

	ptrrand = LFNoise1.kr(20).bipolar(ptrdev);

	// Here, we apply random deviation to the base pointer delay,
	// and prevent it from being lower than necessary grain space:
	ptrdelay = max(ptrdelay - ptrrand, graindur * rate);

	ptr = ptr - (ptrdelay * SampleRate.ir) / BufFrames.kr(buf);

	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: Dust.kr(dens),
		dur: graindur,
		sndbuf: buf,
		rate: rate,
		pos: ptr,
		interp: 2,
		pan: LFNoise1.kr(20).bipolar(pan)
	);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
b.zero;

~srcGrp = Group();
~recGrp = Group(~srcGrp, \addAfter);
~grainGrp = Group(~recGrp, \addAfter);

~mic = Synth(\mic, [
	auxout: ~micbus,
	auxamp: 0.7
], ~srcGrp);

~ptr = Synth(\ptr, [
	buf: b,
	out: ~ptrbus
], ~srcGrp);

~rec = Synth(\rec, [
	ptrin: ~ptrbus,
	in: ~micbus,
	buf: b
], ~recGrp);

~grain = Synth(\grain, [
	ptrin: ~ptrbus,
	buf: b,
	ptrdelay: 1/3,
	ptrdev: 1/3,
	dens: 40,
	graindur: 0.08,
	pan: 0.7,
	out: 0
], ~grainGrp);
)

~grain.set(\gate, 0, \rel, 7);

s.freeAll;

// A few additional tweaks can make this granulator into an even more potent creative tool. Mainly, we take the ranged randomness that was applied to the pan position, and apply similar techniques to grain duration, grain playback rate, and grain density. The following SynthDef also includes the option to specify rhythmic or arhythmic grains, by enclosing Dust and Impulse within a Select UGen. Grains are synchronous when sync is one, and asynchronous when sync is zero.

(
SynthDef(\grain, {
	arg ptrin = 0, gate = 1, atk = 0.01, rel = 3, buf = 0,
	sync = 0, densmin = 30, densmax = 30, graindurmin = 0.07,
	graindurmax = 0.07, ratemin = 1, ratemax = 1, ptrdelay = 0.25,
	ptrdev = 0.15, pan = 0, amp = 1, out = 0;
	var sig, env, ptr, ptrrand, densctrl, graindurctrl, ratectrl, panctrl;

	ptr = In.ar(ptrin, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);
	densctrl = LFNoise1.kr(20).exprange(densmin, densmax);
	graindurctrl = LFNoise1.kr(20).exprange(graindurmin, graindurmax);
	ratectrl = LFNoise1.kr(20).exprange(ratemin, ratemax);
	panctrl = LFNoise1.kr(20).bipolar(pan);

	ptrrand = LFNoise1.kr(20).bipolar(ptrdev);
	ptrdelay = max(ptrdelay - ptrrand, graindurctrl * ratectrl);
	ptr = ptr - (ptrdelay * SampleRate.ir) / BufFrames.kr(buf);

	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: Select.kr(sync, [Dust.kr(densctrl), Impulse.kr(densctrl)]),
		dur: graindurctrl,
		sndbuf: buf,
		rate: ratectrl,
		pos: ptr,
		interp: 2,
		pan: panctrl
	);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

// We are now in possession of a highly versatile real-time granulator. The effect really comes alive when we use iteration, as we did with GrainIn, to create multiple unique granlators operating in parallel. For example, we can create a real-time granular harmonizer. The grains are generated synchronously, at a frequency equal to twice the inverse of the grain duration. This relationship causes each grain to begin as the previous grain reaches its peak, with a 50% overlap between consecutive grains, resulting in a smooth, unwavering sound.

(
b.zero;

~srcGrp = Group();
~recGrp = Group(~srcGrp, \addAfter);
~grainGrp = Group(~recGrp, \addAfter);

~mic = Synth(\mic, [
	amp: 0.5,
	auxout: ~micbus,
	auxamp: 0.5
], ~srcGrp);

~ptr = Synth(\ptr, [
	buf: b,
	out: ~ptrbus
], ~srcGrp);

~rec = Synth(\rec, [
	ptrin: ~ptrbus,
	in: ~micbus,
	buf: b
], ~recGrp);

~grain = [-5, -2, 0, 3].collect({ |n|
	Synth(\grain, [
		ptrin: ~ptrbus,
		buf: b,
		sync: 1,
		ptrdelay: 0.08,
		ptrdev: 0.002,
		densmin: 2 / 0.08,
		densmax: 2 / 0.08,
		graindurmin: 0.08,
		graindurmax: 0.08,
		ratemin: n.midiratio,
		ratemax: n.midiratio,
		pan: 0,
		amp: -2.dbamp,
		out: 0
	], ~grainGrp);
});
)

~grain.do({ |n| n.set(\gate, 0, \rel, 5) });

s.freeAll;

// We can also create a psychedelic text-garbling effect. Because of the pre-fader auxiliary send design of the \mic SynthDef, we can silence the unprocessed signal by zeroing 'amp':

(
var num = 8;

b.zero;

~srcGrp = Group();
~recGrp = Group(~srcGrp, \addAfter);
~grainGrp = Group(~recGrp, \addAfter);

~mic = Synth(\mic, [
	amp: 0, // no direct signal
	auxout: ~micbus,
	auxamp: 0.7
], ~srcGrp);

~ptr = Synth(\ptr, [
	buf: b,
	out: ~ptrbus
], ~srcGrp);

~rec = Synth(\rec, [
	ptrin: ~ptrbus,
	in: ~micbus,
	buf: b
], ~recGrp);

~grain = num.collect({ |n|
	Synth(\grain, [
		ptrin: ~ptrbus,
		buf: b,
		sync: 0,
		ptrdelay: Array.interpolation(num, 0.2, 1.8).at(n),
		ptrdev: rrand(0.1, 0.15),
		densmin: 5,
		densmax: 10,
		graindurmin: 0.05,
		graindurmax: 0.1,
		ratemin: n.linlin(0, num-1, 0, 6).neg.midiratio,
		ratemax: n.linlin(0, num-1, 0, 6).midiratio,
		pan: (Array.rand(8, -0.5, 0.5) * [1, -1]).at(n),
		amp: n.linlin(0, num-1, 0, -16).dbamp,
		out: 0
	], ~grainGrp);
});
)

~grain.do({ |n| n.set(\gate, 0, \rel, 5) });

s.freeAll;

// A granular "freeze" effect is also within reach, by introducing a rate scalar ('run') into the pointer SynthDef. When this value is one, recording (and live granulation) proceeds normally. When this value is zero, the pointer signal stops moving, pausing the recording process and causing the granulator to become "stuck" on a fixed segment of audio.

(
Buffer.freeAll;
b = Buffer.alloc(s, s.sampleRate * 5);

s.newBusAllocators;
~micbus = Bus.audio(s, 1);
~ptrbus = { Bus.audio(s, 1) } ! 2;

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 1, auxamp = 0;
	var sig = SoundIn.ar(in);
	Out.ar(out, sig ! 2 * amp);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\ptr, {
	arg out = 0, buf = 0, run = 1;

	// Proceed if run = 1, freeze if run = 0
	var sig = Phasor.ar(0, BufRateScale.kr(buf) * run, 0, BufFrames.kr(buf));

	Out.ar(out, sig);
}).add;

SynthDef(\rec, {
	arg ptrin = 0, in = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrin, 1);
	sig = In.ar(in, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

SynthDef(\grain, {
	arg ptrin = 0, gate = 1, atk = 0.01, rel = 3, buf = 0,
	sync = 0, densmin = 30, densmax = 30, graindurmin = 0.07,
	graindurmax = 0.07, ratemin = 1, ratemax = 1, ptrdelay = 0.25,
	ptrdev = 0.15, pan = 0, amp = 1, out = 0;
	var sig, env, ptr, ptrrand, densctrl, graindurctrl, ratectrl, panctrl;

	ptr = In.ar(ptrin, 1);
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, -2),
		gate, doneAction: 2
	);
	densctrl = LFNoise1.kr(20).exprange(densmin, densmax);
	graindurctrl = LFNoise1.kr(20).exprange(graindurmin, graindurmax);
	ratectrl = LFNoise1.kr(20).exprange(ratemin, ratemax);
	panctrl = LFNoise1.kr(20).bipolar(pan);

	ptrrand = LFNoise1.kr(20).bipolar(ptrdev);
	ptrdelay = max(ptrdelay - ptrrand, graindurctrl * ratectrl);
	ptr = ptr - (ptrdelay * SampleRate.ir) / BufFrames.kr(buf);

	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: Select.kr(sync, [Dust.kr(densctrl), Impulse.kr(densctrl)]),
		dur: graindurctrl,
		sndbuf: buf,
		rate: ratectrl,
		pos: ptr,
		interp: 2,
		pan: panctrl
	);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
~srcGrp = Group();
~recGrp = Group(~srcGrp, \addAfter);
~grainGrp = Group(~recGrp, \addAfter);

~mic = Synth(\mic, [
	amp: 1,
	auxout: ~micbus,
	auxamp: 0.7
], ~srcGrp);

~ptr = Synth(\ptr, [
	buf: b,
	out: ~ptrbus
], ~srcGrp);

~rec = Synth(\rec, [
	ptrin: ~ptrbus,
	in: ~micbus,
	buf: b
], ~recGrp);

~grain = 3.collect({ |n|
	Synth(\grain, [
		ptrin: ~ptrbus,
		buf: b,
		sync: 0,
		ptrdelay: (n / 5) + 0.1,
		ptrdev: 0.005,
		densmin: 40,
		densmax: 40,
		graindurmin: 0.08,
		graindurmax: 0.12,
		ratemin: -0.2.midiratio,
		ratemax: 0.2.midiratio,
		pan: [-0.3, 0, 0.3].at(n),
		amp: -3.dbamp,
		out: 0
	], ~grainGrp);
});
)

// To demonstrate the freeze, run the following line while singing a steady tone into your microphone:

~ptr.set(\run, 0);

// It is possible to unfreeze the effect by setting rate back to one. However, the freezing effect naturally disrupts the recording process. While the recording is paused, live sound continues. When recording resumes, there will be a discontinuity at the pause point, and thus there may be a few subtle clicks during the initial moments when granulation resumes.

~ptr.set(\run, 1);

// In some contexts, the granulation effect itself might be sufficient to mask the clicks, rendering them negligible. It is also possible (but not trivial) to avoid these clicks. A practical solution involves allocating multiple buffers. After a freeze effect is activated on one buffer, a new set of independent Synths can be created, which start recording into and granulating a second, empty buffer. The original freeze can be sustained indefinitely, or faded out. Once a freeze has been faded out, its buffer can be zeroed and/or reused. This multi-buffer approach is left as an exercise for the adventurous coder.

~grain.do({ |n| n.set(\gate, 0, \rel, 3) });

s.freeAll;

// Experimentation with these granulators is strongly encouraged! They are capable of a wide range of interesting effects.