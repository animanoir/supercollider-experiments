// Companion Code 7.1
// A Simple MIDI Synthesizer

// The MIDI synthesizer example in the book omits some basic features for the sake of simplicity. In that example, we used a finite-duration amplitude envelope and ignored note-off messages, making it impossible to sustain notes. Here, we will build a somewhat more sophisticated MIDI synthesizer, which allows indefinite note sustain and also incorporates pitch bend messages from a pitch wheel. To begin, we boot the server and create a simple triangle wave instrument with a gated envelope.

s.boot;

(
SynthDef(\tone, {
	arg buf = 0, gate = 1, amp = 0.2,
	freq = 220, rel = 0.3, out = 0;
	var sig, env;
	env = Env.asr(0.002, 1, rel).kr(2, gate);
	sig = LFTri.ar(freq * [0, 0.1].midiratio);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\tone);

x.set(\gate, 0);

// Polyphony is the ability of a synthesizer to sound multiple voices simultaneously and independently. In the book example, polyphony was trivial, because each note-on message creates a unique Synth "on demand," and each Synth's release was handled automatically. When using note-off messages to trigger Synth releases, we need to store active Synths such that they are individually addressable. One strategy for MIDI-based polyphony involves creating a array, and storing each new Synth in the array at the index corresponding to its note number. In this way, each Synth has a private "cubby" where it can live, and there is virtually no risk of two notes accidentally sharing the same namespace, stuck notes, or similar problems.

// Since there are 128 possible note numbers, an array of size 128 is a good choice. Each slot in the ~notes array initially contains nil, which represents the absence of a Synth. When a note-on mssage arrives, a Synth object in created and replaces an instance of nil. When a note-off message is received, we release the corresponding Synth and overwrite the Synth reference with nil. Thus, at any point in time, the array represents the physical state of the MIDI keyboard.

(
~notes = Array.newClear(128, nil);

MIDIIn.connectAll;

MIDIdef.noteOn(\on, {
	|val, num, chan, src|
	~notes.put(
		num,
		Synth(\tone, [
			\freq, num.midicps,
			\gate, 1,
			\amp, val.linexp(0, 127, 0.01, 0.25)
		]);
	);
}).permanent_(true);

MIDIdef.noteOff(\off, {
	|val, num, chan, src|
	~notes[num].set(\gate, 0);
	~notes.put(num, nil);
}).permanent_(true);
)

// To incorporate pitch bend, we create a third MIDIdef that responds to pitch bend messages and stores a suitable bend value in a global variable. The data component of a pitch bend message uses 14 bits instead of 7, so the values range from 0 to 16383 instead of 0 to 127. Here, we imagine that the extremes of the pitch wheel correspond to ±2 semitones.

(
MIDIdef.bend(\pitchbend, {
	|val, chan, src|
	~bend = val.linlin(0, 16383, -2, 2);
}).permanent_(true);
)

// To correctly incorporate this data into the rest of our code, several things must happen. First, we must modify the SynthDef so that it includes a new argument, interpreted as a semitone value, which modifies the frequency of the oscillator:

(
SynthDef(\tone, {
	arg buf = 0, gate = 1, amp = 0.2,
	freq = 220, bend = 0, rel = 0.3, out = 0;
	var sig, env;
	env = Env.asr(0.002, 1, rel).kr(2, gate);
	sig = LFTri.ar(freq * [0, 0.1].midiratio * bend.midiratio);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

// Next, we modify the noteOn MIDIdef so that newly created Synths incorporate the current ~bend value:

(
MIDIdef.noteOn(\on, {
	|val, num, chan, src|
	~notes.put(
		num,
		Synth(\tone, [
			\freq, num.midicps,
			\gate, 1,
			\amp, val.linexp(0, 127, 0.01, 0.25),
			\bend, ~bend
		]);
	);
}).permanent_(true);
)

// The previous step handles the application of pitch bend data to Synths as they are created, but does not dynamically apply pitch bend data to currently sounding Synths that have already been created. To do this, the pitch bend MIDIdef must set the bend argument of all existing Synths whenever the pitch wheel moves. The most direct approach is to store all Synths in a Group, and have the bend MIDIdef set the bend argument of that Group, thus relaying the message to all Synths inside. As a convenience, the entire code structure is provided here:

(
~bend = 0;
~group = Group();
~notes = Array.newClear(128, nil);
MIDIdef.freeAll;

MIDIdef.noteOn(\on, {
	|val, num, chan, src|
	~notes.put(
		num,
		Synth(\tone, [
			\freq, num.midicps,
			\gate, 1,
			\amp, val.linexp(0, 127, 0.01, 0.25),
			\bend, ~bend
		], ~group);
	);
}).permanent_(true);

MIDIdef.noteOff(\off, {
	arg val, num, chan, src;
	~notes[num].set(\gate, 0);
	~notes.put(num, nil);
}).permanent_(true);

MIDIdef.bend(\pitchbend, {
	arg val, chan, src;
	~bend = val.linlin(0, 16383, -2, 2);
	~group.set(\bend, ~bend);
}).permanent_(true);
)

// A few additional modifications are possible to enhance this synthesizer, such as using the mod wheel (CC#1) to apply a global vibrato effect, adding sustain pedal functionality (CC#64), or some other MIDI-controllable musical effect. These ideas are left to the reader for exploration.