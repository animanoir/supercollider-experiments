// Companion Code 6.2
// Delay-Based Pitch-Shifting Effects

// The pitch-shifting nature of variable delay lines, and the results they produce when combined with the original signals, are often a defining feature of delay-based effects. These pitch effects enhance a sound's character by adding depth and movement. A chorus effect, for example, uses delay lines to simulate the subtle, irregular detuning that occurs between indiviual voices within a choir of singers — an appealing way to give some "life" to an otherwise flat and boring electronic tone. There is no definitive recipe for a chorus effect, but chorus algorithms often feature a mix of several delay lines whose delay times are each controlled by an independent oscillator or noise generator.

// The following code applies a chorus effect to a live mic signal. The effect uses eight delay lines arranged in parallel. Each delay time is modulated by a triangle wave with a random frequency and initial phase, and these eight monophonic delayed signals are then distributed across the stereo field using Splay.

// FEEDBACK WARNING — use headphones

(
s.options.memSize_(2.pow(20));
s.reboot;
)

(
s.newBusAllocators;
~bus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 0.5, auxamp = 0;
	var sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig ! 2);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\chorus, {
	arg in = 0, amp = 1, maxdel = 0.04, out = 0;
	var sig;
	sig = In.ar(in, 1);
	sig = 8.collect({
		var mod = LFTri.kr(ExpRand(0.2, 0.3), Rand(0.0, 4.0)).range(0.001, maxdel);
		DelayL.ar(sig, maxdel, mod);
	});
	sig = Splay.ar(sig) * amp;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~chorus = Synth(
	\chorus,
	[
		in: ~bus, out: 0,
		amp: 1, maxdel: 0.04
	],
	~mic, \addAfter
);
)

s.freeAll;

// Many variations are possible. The triangle wave can be swapped with another generator (SinOsc, LFNoise1, LFNoise2) for a slightly different flavor of pitch fluctuation. The frequency and/or maximum delay time can be altered to change the depth of the pitch fluctuations; higher values for either parameter will increase the amount of pitch change. Especially high values will produce extreme pitch changes that no longer resemble a chorus effect, but instead create a wide, atonal cluster effect. Further adjustments to the delayed signals might also be implemented within the iteration block, such as amplitude modulation and/or filtering. Keep in mind that 'maxdel' can only be specified once, when the chorus Synth is created; it cannot be changed once DelayL comes into existence and allocates its memory buffer.

// Flanging, chorusing, and related effects are unified by the fact that they adjust a delay time in a manner that fluctuates up and down, such that the pitch of the delayed signal periodically becomes higher and lower over time. However, it's also possible to use delay-based processing to create a fixed pitch-shift effect, in other words, a delayed signal whose output signal remains fixed at a new pitch, different from the pitch of the original.

// As we have already seen, an increasing delay time produces a downward pitch-shift, and a decreasing delay time produces an upward pitch-shift. To produce a constant pitch-shift, the delay time must be changing at a constant rate. However, this introduces a problem. If the delay time is linearly changing, the reading pointer will periodically overtake (or be overtaken by) the writing pointer. When this happens, the reading pointer encounters a discontinuity in the buffer data, marked by the point between the newest recorded sample and the oldest recorded sample. This discontinuity will likely produce a click.

// As an analogy, imagine two cars driving around a narrow circular race track. One car (the writing pointer) is driving at a constant 200 mph. The other car (the reading pointer) is traveling at a constant 190 mph. For a length of time, these cars will have no trouble driving along. But, every now and then, the faster car will creep up behind the slower car. The audible click might be imagined as these cars scraping against each other as one tries to pass the other.

// In Companion Code 4.5, we used BufWr/BufRd to create a similar harmonizer effect and encountered a nearly identical problem. We'll revisit the solution here, from a different perspective.

// The first practical question to address is: Which UGen is appropriate for modulating the delay time so that it will change in a constant, linear manner? LFSaw is an excellent choice, which provides a smooth, repeating ramp shape. Its output should range from 0 to the maximum delay time, and the frequency of the sawtooth oscillator indirectly determines the speed of the internal reading pointer, relative to the internal writing pointer of the delay. For now, we'll supply an arbitrary value and worry about the math later. Note that the following code reuses the \mic SynthDef and ~bus created earlier in this file.

// FEEDBACK WARNING — use headphones

(
SynthDef(\harmonizer, {
	arg in = 0, out = 0, amp = 0.7;
	var sig, phs;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(3).range(0, 0.04);
	sig = DelayL.ar(sig, 0.04, phs);
	sig = sig * amp ! 2;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~harmonizer = Synth(
	\harmonizer,
	[
		in: ~bus, out: 0, amp: 0.7
	],
	~mic, \addAfter
);
)

s.freeAll;

// The effect works well enough, but there are two technical problems. If you sing a steady tone into your microphone, you will hear your voice mixed with a version that is shifted down roughly 2 semitones. The frequency of LFSaw, currently fixed at 3 Hz, determines this pitch-shift amount, but it is not yet clear why a value of 3 translates to approximately -2 semitones, or more generally, what specific frequency is needed to produce a pitch shift of ± n semitones. Additionally, if you sing a steady tone, you will hear a regular sequence of clicks. These clicks are the result of the sample-reading pointer traversing the buffer discontinuity as it bumps into the sample-writing pointer. The frequency of these clicks is determined by the frequency of LFSaw.

// First, we will express the frequency of LFSaw in terms of a desired number of semitones. For the sake of simplicity, we assume the maximum delay time is 1 second long.

// If we want no pitch shift (0 semitones), the frequency of LFSaw should be 0. This produces a waveform which is not really a sawtooth at all, but a flat line. Thus, the delay time is fixed, the reading and writing pointers move at the same speed, and delayed samples are reproduced at their original pitch a short time after they are stored.

// If we want a pitch shift that is an octave lower, the reading pointer should be moving at half the speed of the writing pointer, so that after one second's worth of samples have been stored, the reading pointer has moved halfway through the buffer. Because the delay time is 1 second long, the frequency of the sawtooth wave should be 0.5 Hz.

// If we want a pitch shift that is an octave higher, the reading pointer should be moving at twice the speed of the writing pointer, so that after one second's worth of samples have been stored, the reading pointer will have moved through the buffer twice and met up with the writing pointer again. The frequency of the sawtooth wave in this case should be -1. The negative sign reflects the fact that the pitch shift is in the opposite direction from the previous case. A negative frequency has the side effect of inverting LFSaw so that it produces downward ramp shapes. It may not be immediately obvious why a value of -1 is appropriate (a value of -2 may seem more "correct" on account of needing the reading pointer to move at double-speed). It is important to keep in mind that the output of LFSaw does not determine the *position* of a pointer in the delay buffer, but rather the *distance* between the sample-writing and sample-reading pointers.

// With a frequency of -1, the reading pointer will begin in phase with the writing pointer. At the beginning of a downward ramp cycle, the sawtooth oscillator outputs a large value, near the maximum delay time, so the delay time is relatively long and the reading pointer is far behind the writing pointer. So far, in fact, that it is actually slightly in front of the writing pointer! As the sawtooth ramp cycle descends, the reading pointer is zooming ahead, and catches up to the writing pointer from behind after 1 second has elapsed. Thus, the reading pointer has traversed the delay buffer a total of two times, and is thus moving at twice the speed of the writing pointer.

// The correct frequency of LFSaw can be expressed in term of ± n semitones as:

(2.pow(n / 12) - 1).neg;

// Or, alternatively, by using the midiratio method:

(n.midiratio - 1).neg;

(-12.midiratio - 1).neg; // -> 0.5
(0.midiratio - 1).neg; // -> 0.0
(12.midiratio - 1).neg; // -> -1
(5.midiratio - 1).neg; // -> -0.3348... (LFSaw frequency that produces a +5 semitone shift)

// We can also visually display this relationship using a Plotter:

(
(-12..12).collect({ |n| (n.midiratio - 1).neg }).plot
.specs_(ControlSpec(-1, 1, 'lin', 0.1, 0, "Hz"))
.domainSpecs_(ControlSpec(-12, 12, 'lin', 1, 0, "semitones"))
.domain_((-12..12))
)

// These values are built on the assumption that the delay buffer is 1 second long. However, in a practical implementation, this is probably too long — at times, the harmonized signal will be close to 1 second behind the live signal, and will sound audibly delayed, rather than sounding like a real-time harmonization. A much shorter buffer is appropriate, but too short, and the harmonized signal will begin to exhibit glitchy artifacts, on account of being unable to store a sufficiently large amount of signal data. Regardless of our buffer size, our semitone-to-Hz expression must be scaled by the length of the buffer. In other words, we must divide the sawtooth frequency by the maximum delay time. Thus, we can write our SynthDef as follows:

// FEEDBACK WARNING — use headphones

(
SynthDef(\harmonizer, {
	arg in = 0, out = 0, trnsp = 0, maxdel = 0.04, amp = 0.7;
	var sig, phs, sawrate;
	sawrate = (trnsp.midiratio - 1).neg;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(sawrate / maxdel).unipolar(1);
	sig = DelayL.ar(sig, maxdel, phs * maxdel);
	sig = sig * amp ! 2;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(
	\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~harmonizer = Synth(
	\harmonizer,
	[
		in: ~bus, out: 0, amp: 0.7
	],
	~mic, \addAfter
);
)

// The default 'trnsp' value is zero (no transposition), but we can freely alter it with set messages. Relatively small transposition amounts sound reasonably realistic. As the transposition value moves further away from zero, the results sound increasingly artificial.

~harmonizer.set(\trnsp, -2);

~harmonizer.set(\trnsp, 3);

s.freeAll;

// Finally, we need to remove these clicks. We can't avoid the reading/writing pointers crossing paths, but we can anticipate the location of each click and fade it out by modulating the amplitude of the delayed signal using a periodic oscillator that is phase-locked to the sawtooth oscillator. When LFSaw outputs a value of 0, the delay time is 0. This moment is where the click occurs. We can create the necessary envelope function using trigonometry. Specifically, we scale the sawtooth wave to a range between 0 and 2π, and take the cosine. The normal range of the cosine function is -1 to +1, and the value of cos(0) equals 1, so we need to remap the cosine output so that its range is between 0 and 1, and forms an upside-down bell curve shape. We can do this with 'linlin':

// the normal cosine function (note the y-axis range)
cos((0, 0.01..4) * 2pi).plot(bounds: Rect(40, 40, 800, 200));

// our remapped cosine function (note the y-axis range)
cos((0, 0.01..4) * 2pi).linlin(-1, 1, 1, 0).plot(bounds: Rect(40, 40, 800, 200));

// So, we can rewrite our SynthDef like this:

(
SynthDef(\harmonizer, {
	arg in = 0, out = 0, trnsp = 0, maxdel = 0.04, amp = 0.7;
	var sig, phs, sawrate, env;
	sawrate = (trnsp.midiratio - 1).neg;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(sawrate / maxdel).unipolar(1);
	sig = DelayL.ar(sig, maxdel, phs * maxdel);
	env = cos(phs * 2pi).linlin(-1, 1, 1, 0);
	sig = sig * env * amp ! 2;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(
	\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~harmonizer = Synth(
	\harmonizer,
	[
		in: ~bus, out: 0, amp: 0.7
	],
	~mic, \addAfter
);
)

// We're almost finished. When we transpose the pitch, the clicks are gone,  replaced by a recurring amplitude "dip":

~harmonizer.set(\trnsp, -2);

~harmonizer.set(\trnsp, 3);

s.freeAll;

// A practical solution is to create two summed delay lines, whose delay times are controlled by two sawtooth waves that are 180 degrees out of phase relative to each other. Their periodic envelope signals, too, will be 180 degrees out of phase with each other. As one delay line fades out to remove the click, the other delay line fades in to compensate, and vice-versa. These two delay signals work together to produce a delayed signal with a constant amplitude and no clicks.

// Multichannel expansion handles this change beautifully. We need only to supply LFSaw with a phase value of [0, 1], which creates the array of two out-of-phase sawtooths, and sum the two delay signals before applying amp ! 2:

(
SynthDef(\harmonizer, {
	arg in = 0, out = 0, trnsp = 0, maxdel = 0.04, amp = 0.7;
	var sig, phs, sawrate, env;
	sawrate = (trnsp.midiratio - 1).neg;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(sawrate / maxdel, [0, 1]).unipolar(1);
	sig = DelayL.ar(sig, maxdel, phs * maxdel);
	env = cos(phs * 2pi).linlin(-1, 1, 1, 0);
	sig = (sig * env).sum * amp ! 2;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(
	\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~harmonizer = Synth(
	\harmonizer,
	[
		in: ~bus, out: 0, amp: 0.7
	],
	~mic, \addAfter
);
)

~harmonizer.set(\trnsp, -2);

~harmonizer.set(\trnsp, 3);

s.freeAll;

// The result still has a slightly audible "pulsing" sound, a result of the modulating envelopes. For a slight improvement, we can take the square root of the envelope functions, which slightly "bends" them upward. This operation produces an equal-power crossfade between the delays instead of an equal-amplitude crossfade, which provides a more uniform perception of loudness:

(
[
	// The original cosine amplitude functions:
	cos((0, 0.01..4) * 2pi).linlin(-1, 1, 1, 0),
	cos((0, 0.01..4).rotate(50) * 2pi).linlin(-1, 1, 1, 0)
].plot(bounds: Rect(40, 40, 800, 400));
)

(
[
	// The modified sqrt(cosine) amplitude functions:
	cos((0, 0.01..4) * 2pi).linlin(-1, 1, 1, 0).sqrt,
	cos((0, 0.01..4).rotate(50) * 2pi).linlin(-1, 1, 1, 0).sqrt
].plot(bounds: Rect(40, 40, 800, 400));
)

(
SynthDef(\harmonizer, {
	arg in = 0, out = 0, trnsp = 0, maxdel = 0.04, amp = 0.7;
	var sig, phs, sawrate, env;
	sawrate = (trnsp.midiratio - 1).neg;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(sawrate / maxdel, [0, 1]).unipolar(1);
	sig = DelayL.ar(sig, maxdel, phs * maxdel);
	env = cos(phs * 2pi).linlin(-1, 1, 1, 0).sqrt;
	sig = (sig * env).sum * amp ! 2;
	Out.ar(out, sig);
}).add;
)

(
~mic = Synth(
	\mic,
	[
		in: 0, out: 0, auxout: ~bus,
		amp: 0.5, auxamp: 1
	]
);

~harmonizer = Synth(
	\harmonizer,
	[in: ~bus, out: 0, amp: 0.7],
	~mic, \addAfter
);
)

~harmonizer.set(\trnsp, -2);

~harmonizer.set(\trnsp, 3);

s.freeAll;

// For one final demonstration, the following code passes the live signal through several harmonizers in parallel to create a chord, and then passes the harmonizer mix through the chorus effect from the beginning of this companion code:

(
s.newBusAllocators;
~hbus = Bus.audio(s, 1);
~cbus = Bus.audio(s, 1);

SynthDef(\mic, {
	arg in = 0, out = 0, auxout = 0, amp = 0.5, auxamp = 0;
	var sig;
	sig = SoundIn.ar(0);
	Out.ar(out, sig * amp ! 2);
	Out.ar(auxout, sig * auxamp);
}).add;

SynthDef(\harmonizer, {
	arg in = 0, out = 0, trnsp = 0, maxdel = 0.04, amp = 0.7;
	var sig, phs, sawrate, env;
	sawrate = (trnsp.midiratio - 1).neg;
	sig = In.ar(in, 1);
	phs = LFSaw.ar(sawrate / maxdel, [0, 1]).unipolar(1);
	sig = DelayL.ar(sig, maxdel, phs * maxdel);
	env = cos(phs * 2pi).linlin(-1, 1, 1, 0).sqrt;
	sig = (sig * env).sum * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\chorus, {
	arg in = 0, amp = 1, maxdel = 0.04, out = 0;
	var sig;
	sig = In.ar(in, 1);
	sig = 8.collect({
		var mod = LFTri.kr(ExpRand(0.2, 0.3), Rand(0.0, 4.0)).range(0.001, maxdel);
		DelayL.ar(sig, maxdel, mod);
	});
	sig = Splay.ar(sig) * amp;
	Out.ar(out, sig);
}).add;
)

(
~srcGroup = Group();
~harmonizerGroup = Group(~srcGroup, \addAfter);
~chorusGroup = Group(~harmonizerGroup, \addAfter);

~mic = Synth(
	\mic,
	[
		in: 0, out: 0, auxout: ~hbus,
		amp: 0, auxamp: 1
	],
	~srcGroup
);

~harmonizer = [-5, -3, 0, 4].collect({ |n|
	Synth(
		\harmonizer,
		[
			in: ~hbus, out: ~cbus, amp: 0.5, trnsp: n
		],
		~harmonizerGroup
	);
});

~chorus = Synth(
	\chorus,
	[
		in: ~cbus, out: 0,
		amp: 1, maxdel: 0.02
	],
	~chorusGroup
);
)

s.freeAll;