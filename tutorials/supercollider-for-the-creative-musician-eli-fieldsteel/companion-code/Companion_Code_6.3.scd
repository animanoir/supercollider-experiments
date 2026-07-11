// Companion Code 6.3
// Delay-Based Reverb Design

// As a sound propagates throughout an indoor space, sound waves reflect off various surfaces, forming complex patterns and showering our eardrums with thousands of delayed copies. In a well-designed space, these reverberant echoes immerse the listener, providing a pleasant and arguably essential component of the listening experience. Feedback delay lines, such as comb filters and all-pass filters, are excellent tools for modeling the natural reverberant behavior of rooms and concert halls, provided that the simulated echoes are dense and uncorrelated enough to avoid flutter echo, and that the frequency response of the reverberant sound is flat enough to avoid audible spectral coloration.

// Though SC includes a few pre-built reverberators (FreeVerb, FreeVerb2, and GVerb), it is instructive to build our own reverb effect using a combination of simpler delay UGens, an approach that also offers more flexibility and customization options.

// In his 1961 article "Natural Sounding Artificial Reverberation," M. R. Schroeder outlines several reverb algorithms designed to sound indistinguishable from natural room reverberation. The ideas in this Companion Code are derived from Schroeder's ideas, though a few creative liberties have been taken.

(
s.newBusAllocators;
~bus = Bus.audio(s, 2);
s.options.memSize_(2.pow(20));
s.reboot;
)

// A simple enveloped sine wave generator will serve as the source sound for auditioning various reverb algorithms, but this source can be swapped with any sound source you might prefer.

(
SynthDef(\sin, {
	arg freq = 440, amp = 0.25, out = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.ar(Env.perc(0.001, 0.14), doneAction:2);
	sig = sig * env * amp ! 2;
	Out.ar(out, sig);
}).add;
)

Synth(\sin, [\freq, exprand(180, 2500)]); // evaluate repeatedly

// A single all-pass filter provides a hint of reverb, but by itself it cannot provide the necessary density and complexity:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.5;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = AllpassN.ar(sig, 0.05, 0.05, 3);
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]); // evaluate repeatedly

// Remember to free each reverb effect or press [cmd]+[period] before moving onto each subsequent demonstration:

~r.free;

// A serial arrangement of several all-pass filters has a multiplicative effect on the number of audible echoes. If each all-pass filter has a sufficiently short delay time (uncorrelated with the others) and a sufficiently long decay time, we only need about 4 or 5 all-pass filters to achieve an acceptable density level:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.25;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = In.ar(in, 2);
	5.do({ wet = AllpassN.ar(wet, 0.1, Rand(0.02, 0.1), 3) });
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// Despite its simplicity, the quality of this reverb effect is already surprisingly good. A few minor changes can further enhance a sense of realism. A short time delay, inserted just before the all-pass filters, will simulate the initial time delay between the arrival of the direct sound at the ears and the arrival of early reflections (referred to as "pre-delay" on many reverb plug-ins). A value of 0.03 seconds is a good starting point, but this can be slightly increased or decreased to simulate different amounts of physical space. We can also apply mathematical constraints to the randomly-selected delay times, to ensure that they are all selected from different random ranges. This helps distribute and decorrelate the random delay times more evenly, and produces a more diffuse and balanced sound:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.25;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.03, 0.03); // pre-delay
	5.do({ |n|
		var del;
		// 1st value randomly selected between 0.05 - 0.1
		// 2nd between 0.333 - 0.05
		// 3rd between 0.025 - 0.333, etc.
		del = Rand(0.1 / (n + 2), 0.1 / (n + 1));
		wet = AllpassN.ar(wet, 0.1, del, 3);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// The previous reverb effect is monophonic — it applies the exact same delay characteristics to both input channels. We can create a stereo version by applying multichannel expansion to the randomly selected delay times. The result is subtle, but definitely noticeable, especially on headphones:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.25;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.03, 0.03);
	5.do({ |n|
		var del;
		del = { Rand(0.1 / (n + 2), 0.1 / (n + 1)) } ! 2; // stereo effect
		wet = AllpassN.ar(wet, 0.1, del, 3);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// Decay time is defined as the number of seconds it takes for the level of a feedback delay signal to decrease by 60 dB. In the world of digital audio, most feedback delays express the decay time in terms of a nominal coefficient by which the delayed output is scaled before being fed back into the delay. A coefficient of 0.5 means the amplitude is reduced by half (-6 dB) between each delay cycle, a value of 0.25 corresponds to -12 dB, etc. SC is slightly unusual in that the user provides a decay time explicitly, as a value in seconds. Internally, SC calculates the necessary coefficient using the following (simplified) formula:

coef = 0.001.pow(delay / decay);

// For example, if the delay time is 0.1 seconds, and the decay time is 1 second, the coefficient is approximately 0.5:

0.001.pow(0.1 / 1); // -> 0.501187...

// We can give ourselves the option of expressing the decay time as a nominal coefficient by undoing this math in the SynthDef. By algebraically rearranging the equation, we can express the decay time as:

decay = delay / (log10(coef) / 3.neg);

// If the coefficient is 0.5 and the delay time is 0.1, we can verify that the decay time comes out to about 1 second:

0.1 / (log10(0.5) / 3.neg); // -> 0.996578...

// Thus, we can rewrite our reverb SynthDef as follows. This change does not noticeably alter the sound quality, but rather provides a mathematical alternative for expressing the decay time. Many of Schroeder's examples gravitate toward a gain coefficient of 0.7. Here, the coefficient for each of the five all-pass filters is randomly selected between 0.6 and 0.75:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.25;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.03, 0.03);
	5.do({ |n|
		var del, coef, dec;
		del = { Rand(0.1 / (n + 2), 0.1 / (n + 1)) } ! 2;
		coef = Rand(0.6, 0.75);
		dec = del / (log10(coef) / 3.neg);
		wet = AllpassN.ar(wet, 0.1, del, dec);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

// We have already included a 'mix' argument that controls the blend of direct sound with reverberant sound:

~r.set(\mix, 0.05); // relatively dry

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.set(\mix, 0.4); // relatively wet

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// In his discussions on mixing direct sound with reverberant sound, Schroeder describes a refinement to the algorithm which includes an additional feedback path by which the output of the entire pre-delay/all-pass network is fed back into itself after a gain adjustment. This refinement can be roughly emulated using LocalIn and LocalOut:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.25, fb = 0.8;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = LocalIn.ar(2) + sig; // read from local bus
	wet = DelayN.ar(wet, 0.03, 0.03);
	5.do({ |n|
		var del, coef, dec;
		del = { Rand(0.1 / (n + 2), 0.1 / (n + 1)) } ! 2;
		coef = Rand(0.6, 0.75);
		dec = del / (log10(coef) / 3.neg);
		wet = AllpassN.ar(wet, 0.1, del, dec);
	});
	LocalOut.ar(wet * fb); // apply feedback coefficient write to local bus
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

// This additional layer of feedback delay provides excellent density and spectral uniformity. At this point, we can easily change the "size" of the reverb by adjusting this large-scale feedback coefficient:

~r.set(\fb, 0.95); // very long reverb tail

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.set(\fb, 0.3); // shorter reverb tail

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

// We can bypass the outer feedback layer entirely, effectively returning to the previous version of this SynthDef:

~r.set(\fb, 0); // outer feedback layer bypassed

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

// The beautifully flat frequency response of the all-pass filter is on full display if the feedback coefficient is set to one, which creates an infinite-length reverb effect that is stable and resonance-free. If we were to attempt this infinite reverb effect with comb filters instead of all-pass filters, the natural resonances would likely spiral out of control and overwhelm the effect (experiment with this at your own risk)! Of course, even in the case of all-pass filters, the reverb tails of successive sound sources will gradually accumulate, so a feedback coefficient just slightly less than one is arguably safer. Some amount of trial and error is appropriate to find the right balance between stability and the infinite nature of this effect.

~r.set(\fb, 0.998);

// run multiple times:
Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.set(\fb, 0.8);

~r.free;

// In reality, an average room or concert hall does not have a perfectly flat frequency response. Instead, such a room has resonant modes at certain frequencies as a result of its size and dimensions. Thus, incorporating a few comb filters into our reverb design may actually improve a sense of realism by providing some slight spectral coloration. Schroeder suggets four comb filters in parallel, with delay times between 0.03 and 0.045 seconds, and gain coefficients no greater than 0.85 (to avoid excessive coloration), followed by multiple all-pass filters in series. Because the comb filters provide part of the reverberation body, only 2 all-pass filters are needed to create the minimum required density. Schroeder suggests all-pass delay times of 5 and 1.7 milliseconds, and gain coefficients of 0.7.

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.15;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.03, 0.03);
	wet = 4.collect({
		var del, coef, dec;
		del = { Rand(0.03, 0.045) } ! 2;
		coef = Rand(0.7, 0.85);
		dec = del / (log10(coef) / 3.neg);
		CombN.ar(wet, 0.1, del, dec);
	}).sum;
	[0.0017, 0.005].do({ |del|
		var dec;
		dec = (del / (log10(0.7) / 3.neg));
		wet = AllpassN.ar(wet, 0.1, del, dec);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// Whether this reverb effect is superior to the version without comb filters is a purely subjective judgement. It is important to note that an additional layer of feedback via LocalIn/LocalOut is not adviseable here, due to the presence of comb filters. If this local feedback path were added, even feedback coefficients well below 1 may produce unstable resonances that exhibit exponentially increasing amplitudes.

// It's also important to remember that numerous parameters here can be tweaked, such as the pre-delay duration, the delay times, the gain coefficients, and the quantity of comb filters/all-pass filters. In the following example, the parameters have been adjusted to create a somewhat more spacious effect:

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.2;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.04, 0.04);
	wet = 4.collect({
		var del, coef, dec;
		del = { Rand(0.03, 0.07) } ! 2;
		coef = Rand(0.75, 0.85);
		dec = del / (log10(coef) / 3.neg);
		CombN.ar(wet, 0.1, del, dec);
	}).sum;
	3.do({ |n|
		var del, coef, dec;
		del = { Rand(0.002, 0.01) } ! 2;
		coef = Rand(0.8, 0.95);
		dec = (del / (log10(coef) / 3.neg));
		wet = AllpassN.ar(wet, 0.1, del, dec);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus, mix: 0.2]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;

// Low-pass filters are common additions to reverb effects, which help shave away high frequency regions to create a darker, warmer sound. This characteristic is often referred to as "damping," which simulates a reverberant space that more readily absorbs high frequencies while reflecting lower frequencies. The quantity, placement, and cutoff frequencies of such filters are flexible, and experimentation is encouraged. Here, as one possible example, the output of each comb filter is passed through a low-pass filter, each with a unique cutoff frequency between 1000 and 1500 Hz.

(
SynthDef(\reverb, {
	arg in = 0, out = 0, mix = 0.2;
	var sig, wet;
	sig = In.ar(in, 2);
	wet = DelayN.ar(sig, 0.04, 0.04);
	wet = 4.collect({
		var del, coef, dec;
		del = { Rand(0.03, 0.07) } ! 2;
		coef = Rand(0.75, 0.85);
		dec = del / (log10(coef) / 3.neg);
		LPF.ar(CombN.ar(wet, 0.1, del, dec), { ExpRand(1000, 1500) } ! 2);
	}).sum;
	3.do({ |n|
		var del, coef, dec;
		del = { Rand(0.002, 0.01) } ! 2;
		coef = Rand(0.8, 0.95);
		dec = (del / (log10(coef) / 3.neg));
		wet = AllpassN.ar(wet, 0.1, del, dec);
	});
	sig = sig + (wet * mix);
	Out.ar(out, sig);
}).add;
)

~r = Synth(\reverb, [in: ~bus, mix: 0.2]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;