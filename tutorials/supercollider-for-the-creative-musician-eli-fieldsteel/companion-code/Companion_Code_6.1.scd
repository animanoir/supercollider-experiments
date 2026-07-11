// Companion Code 6.1
// Emulating the Signal Flow of an Analog Mixer

// The design concepts that govern signal flow on the audio server are similar to the signal flow concepts found on analog/digital mixers. Both rely on implementations involving audio channels, busses, inputs & outputs, routing, auxiliary sends, groups, and so on. When working with a large collection of signals in SC, it can be advantageous to create one or more SynthDefs that emulate mixer behavior, and install these Synths at the tail end of the node tree, where they operate as a bottleneck that receives upstream channels, allows various adjustments, and mixes them into one stereo output signal.

s.boot;

(
// First, we allocate a few stereo audio busses to represent signal pathways on our imaginary mixer. To keep things simple, we'll imagine that this mixer has four stereo input channels, a single stereo auxiliary send/return path, and a single "main" output channel where all signals are collected before being sent to loudspeakers.

s.newBusAllocators;
~faderBus = 4.collect({ Bus.audio(s, 2) }); // array of stereo input channels
~auxSend = Bus.audio(s, 2); // aux send & return busses
~auxReturn = Bus.audio(s, 2);
~mainBus = Bus.audio(s, 2); // path to main L/R output channel
~outBus = 0;

// The following SynthDef represents the combination of a level fader, a pan knob, and a mute button, all typically found on a mixer input channel strip. 'amp' determines the position of the fader, 'pan' determines the position of the knob, and 'on' represents our ability to mute the signal. The signal passes when on = 1, and is muted when on = 0. The 'amp' parameter is lagged to provide a time delay when the level changes, emulating the physical movement of an analog fader.

// Note that this SynthDef has two outputs, just like an input channel on a mixer has several output routing options. 'out' represents the main output path, which goes directly to the output section of a mixer. 'auxout' represents an auxiliary send path, and 'auxamp' represents the level of the aux send knob. This particular design emulates a post-fader aux send, because the main amplitude ('amp') is applied before the send level ('auxamp') is applied. To create a pre-fader send, the multiplication of 'amp' (and possibly 'on') would occur with the 'sig' that's inside the first Out UGen, making it completely independent from the auxiliary send.

SynthDef(\fader, {
	arg in = 0, on = 1, pan = 0, amp = 1, lag = 1,
	auxamp = 0, out = 0, auxout = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * amp.varlag(lag, -1) * on;
	Out.ar(out, sig);
	Out.ar(auxout, sig * auxamp);
}).add;

// This next SynthDef represents the output section of a simple mixer. It takes a stereo channel from upstream, conceived as (1) the direct signal from an input channel and (2) the return signal from one or more effects. These two signals are summed, and the same 'amp'/'on' combination is applied before the signal is sent out.

SynthDef(\main, {
	arg in = 0, auxin = 0, inamp = 1, auxamp = 1,
	amp = 1, lag = 1, on = 1, out = 0;
	var sig, auxsig;
	sig = In.ar(in, 2) * inamp;
	auxsig = In.ar(auxin, 2) * auxamp;
	sig = (sig + auxsig) * amp.varlag(lag, -1) * on;
	Out.ar(out, sig);
}).add;

// We also create a reverb SynthDef, adapted from Code Example 6.13, to model an external signal processing effect. A 'mix' value of 1 establishes a reverb effect in which the output signal is 100% processed ("wet"), with none of the original "dry" signal mixed in. This is appropriate for our auxiliary send model, because we already have a direct output path for the unprocessed "dry" signal.

SynthDef(\reverb, {
	arg in = 0, out = 0, size = 0.99, amp = 1;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: size);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
// This next chunk of code emulates the process of turning on the equipment and making connections with audio cables. We first create three Groups, positioned in series after the default group, which might represent "rack spaces" for the mixer input section, outboard effects, and mixer output section.

~faderGroup = Group(s.defaultGroup, \addAfter);
~auxGroup = Group(~faderGroup, \addAfter);
~mainGroup = Group(~auxGroup, \addAfter);

// We then instantiate (or "power on") four stereo input channels on the mixer, the reverb effect, and the main output fader.

~fader = 4.collect({ |n|
	Synth(\fader,
		[
			in: ~faderBus[n],
			auxout: ~auxSend,
			out: ~mainBus,
		],
		~faderGroup
	);
});

~reverb = Synth(\reverb,
	[
		in: ~auxSend,
		out: ~auxReturn
	],
	~auxGroup
);

~mainFader = Synth(\main,
	[
		in: ~mainBus,
		auxin: ~auxReturn,
		out: ~outBus,
	],
	~mainGroup
);
)

// Now is a good moment to view the node tree to visualize our signal flow:

s.plotTree;

(
// The following SynthDef serves as a sound source to be connected to an input channel on our mixer. This SynthDef uses GrainBuf to granulate one of SC's two built-in sound files, and includes arguments that control the grain position range, playback rate, and overall amplitude.

~b0 = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01.wav");
~b1 = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01-44_1.aiff");

SynthDef(\drone, {
	arg buf = 0, posmin = 0, posmax = 0.01,
	gate = 1, rate = 1, amp = 1, out = 0;
	var sig, env, pos, ampmod;
	pos = LFNoise0.kr(100).range(posmin, posmax);
	sig = GrainBuf.ar(2, Dust.kr(100), 0.05, buf, rate, pos);
	ampmod = LFNoise1.kr(12).exprange(0.01, 1);
	sig = sig * ampmod * amp;
	Out.ar(out, sig);
}).add;
)

(
// Being responsible audio engineers, we'll start with our "faders" all the way down:

~fader.do({ |n| n.set(\amp, 0) });
~mainFader.set(\amp, 0);
)

(
// We'll now "power on" four stereo sound sources, each routed to a different stereo input channel on our mixer. Because the faders are down, we won't hear anything just yet.

Synth(\drone, [
	buf: ~b0, posmin: 0.8, posmax: 0.81,
	rate: 1, amp: 0.8, out: ~faderBus[0]
]);
Synth(\drone, [
	buf: ~b1, posmin: 0, posmax: 0.1,
	rate: 3.2, amp: 0.3, out: ~faderBus[1]
]);
Synth(\drone, [
	buf: ~b0, posmin: 0.3, posmax: 0.35,
	rate: 0.4, amp: 0.7, out: ~faderBus[2]
]);
Synth(\drone, [
	buf: ~b1, posmin: 0.65, posmax: 0.75,
	rate: 1.1, amp: 0.6, out: ~faderBus[3]
]);
)

// We can confirm that these Synths have been added by viewing the node tree again (if it's not already visible):

s.plotTree;

// Now, we can begin interacting with our imaginary mixer. First, we'll bring up main fader to a nominal level:

~mainFader.set(\amp, 1);

// and slowly bring up each fader to a -6 dB level, one at a time:

~fader[0].set(\amp, -6.dbamp, \lag, 3);

~fader[1].set(\amp, -6.dbamp, \lag, 3);

~fader[2].set(\amp, -6.dbamp, \lag, 3);

~fader[3].set(\amp, -6.dbamp, \lag, 3);

// We can experiment with the pan positions on each of the four input channels. For instance, we can pan all four sources hard left:

~fader.do({ |n| n.set(\pan, -1) }); // all hard left

// We can pan these four signals L/R in alternating fashion:

[~fader[1],~fader[3]].do({ |n| n.set(\pan, 1) });

// Or, we can set them all to a central position with a bit of randomness:

~fader.do({ |n| n.set(\pan, rrand(-0.25, 0.25)) });

// For the moment, we'll mute channels 0, 1, and 3, so that we can focus on channel 2:

~fader[[0, 1, 3]].do({ |n| n.set(\on, 0) });

// In addition to the main path to the output section of the mixer, let's also route this signal to the auxiliary send, which will pass through the reverb unit. We've already established the signal connection to the ~auxSend bus when we created the fader Synths, so all we need to do is turn up the aux "knob." To start, we'll set the send amount to a subtle -25 dB, at which point the effect will be barely audible.

~fader[2].set(\auxamp, -25.dbamp);

// By cranking the send knob up to -3 dB, the effect becomes very pronounced:

~fader[2].set(\auxamp, -3.dbamp);

// -18 dB might be a decent compromise, but of course, reverb level is a matter of taste and context:

~fader[2].set(\auxamp, -18.dbamp);

// Next, we'll set the aux send level on all four channels to be -18 dB:

~fader.do({ |n| n.set(\auxamp, -18.dbamp) });

// And unmute the other input channels, allowing all four to pass through the reverb unit:

~fader.do({ |n| n.set(\on, 1) });

// The "mainFader" Synth receives the "dry" signal mix from the faders, as well as the summed "wet" output from the reverb. These two mixes have individual level controls:

~mainFader.set(\inamp, 0); // dry signal silenced
~mainFader.set(\inamp, 1); // dry signal present

~mainFader.set(\auxamp, 0); // reverb silenced
~mainFader.set(\auxamp, 1); // reverb present

// We also have control over the entire sound via the 'amp' level of the main fader:

~mainFader.set(\amp, -6.dbamp, \lag, 3); // slowly down to -6 dB

~mainFader.set(\amp, -18.dbamp, \lag, 3); // slowly down further to -18 dB

~mainFader.set(\amp, 0, \lag, 0.2); // quickly down to silent

(
// For quick cleanup, we can simply free all nodes and buffers:
s.freeAll;
Buffer.freeAll;
)

// This code intentionally showcases a relatively simple mixer emulation, which includes only the bare essentials. The fader Synth could be expanded to include EQ controls (e.g. BLowShelf, BHiShelf, MidEQ, or other filter UGens) and possibly dynamic range compression (Compander/Limiter). We can allocate even more busses, perhaps a combination of mono/stereo busses, to expand our input capabilities. The "mainFader" Synth could both be expanded to include more "mix" channels, for example, to receive separate signals from different processing effects. These and other explorations are left as an open exercise for the reader.
