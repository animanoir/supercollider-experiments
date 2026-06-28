(
// --- 1. SETUP ---
// Ideally, change this path to a folder on your own computer containing WAV files.
var folderPath = "/Users/oscarmontiel/Desktop/sonidos/poema-1-oam/adjetivos/";

s.waitForBoot({
	var pathObj, soundFiles;

	pathObj = PathName(folderPath);
	if(pathObj.isFolder, {
		soundFiles = pathObj.entries.select({ |file|
			file.extension.toLower == "wav"
		});
		soundFiles.postln;
	}, { "The folder doesn't exists.".warn; soundFiles = []; });

	~buffers = soundFiles.collect({ |file|
		Buffer.readChannel(s, file.fullPath, channels: [0]);
	});

	s.sync;
	("✅ SETUP COMPLETE. " ++ ~buffers.size ++ " files loaded.").postln;
});
)


(
// --- INSTRUMENT/SYNTH DEFINITION ---
SynthDef(\glitchStretch, {
	arg bufnum, amp = 0.5, pan = 0.0, glitchFreq = 2.0, duration = 5.0, windowSize = 1.0, overlaps = 8;

	var sig, pointer, currentRate, brokenRate, isGlitching, isFreezing, freezeRate, env, isFinished;
	var dice;

	// 1. SPEED CONTROL (Faster and with freezes)
	// Think of this as the motor of a tape player that is malfunctioning.
	brokenRate = LFNoise1.kr(glitchFreq).range(0.6, 1.8);

	// Dice roll that decides if we glitch.
	// Returns 1 (true) if the noise value is > 0.7, otherwise 0.
	dice = LFNoise0.kr(1).range(0, 1) > 0.7;
	isGlitching = dice;
	// ("Dice value: "++dice++" Does it glitch? "++isGlitching).postln;

	// The "dice" that decides if we freeze the sound (stop the playhead).
	isFreezing = LFNoise0.kr(0.5).range(0, 1) > 0.85; // 15% chance of freeze

	// Freeze rate (very slow, almost motionless texture).
	freezeRate = LFNoise1.kr(0.2).range(0.1, 1.0);

	// Select the playback speed.
	// First, we choose between normal (1.0) or glitchy (brokenRate).
	currentRate = Select.kr(isGlitching, [1.0, brokenRate]);
	// Then, we decide if we override that with the "freeze" rate.
	// .lag(0.3) makes the speed change smooth, like a heavy flywheel slowing down.
	currentRate = Select.kr(isFreezing, [currentRate, freezeRate]).lag(0.3);

	// 2. THE POINTER (Here is the magic change)
	// Instead of Phasor (which loops repetitively), we use Sweep.
	// Sweep integrates the velocity over time.
	// If the velocity drops (freeze), Sweep advances very slowly.
	// The math formula to go from 0 to 1 across the buffer is: Rate / BufferFrameCount
	pointer = Sweep.ar(1, (BufRateScale.kr(bufnum) * currentRate) / BufFrames.kr(bufnum));

	// 3. THE FINISH LINE (The race referee)
    // We ask: "Have you crossed the finish line (1.0) yet?"
    isFinished = pointer >= 1.0;

	// The envelope stays open as long as we haven't finished (gate: 1 - isFinished).
	env = EnvGen.kr(Env.linen(1.0, duration, 2.0), gate: (1 - isFinished), doneAction: 2);

	// 4. THE GRANULAR PLAYER (Warp1)
	// freqScale: 1.0 means "original pitch".
	// windowSize: 0.1 is the size of the "grain" (the slice of audio).
	// overlaps: 8 smooths the sound by layering 8 grains on top of each other.
	sig = Warp1.ar(1, bufnum, pointer, freqScale: 1.0, windowSize: windowSize, envbufnum: -1, overlaps: overlaps, windowRandRatio: 0.5);

	// A bit of analog "dirt/grit" or amplitude modulation.
	sig = sig * SinOsc.kr(LFNoise1.kr(0.5).range(1, 3)).range(0.7, 1.0);

	sig = sig * env;

	sig = Pan2.ar(sig, pan, amp);
	Out.ar(0, sig);
}).add;
)

// --- 2. THE INTELLIGENT SEQUENCER ---
(
Tdef(\pianoGranular, {
	// Create a "deck of cards" with our buffers and shuffle them endlessly.
	var deckDeBuffers = Pshuf(~buffers, inf).asStream;

	loop {
		var chosenBuf = deckDeBuffers.next;
		// Define how long THIS specific sound cloud will last.
		var lifeTime = 0.5.rrand(1.0);

		if(chosenBuf.notNil) {

			// Trigger the Synth and tell it how long to live.
			Synth(\glitchStretch, [
				\bufnum, chosenBuf,
				\amp, 0.1.rrand(0.4), // Lower amp slightly to avoid distortion when voices overlap.
				\duration, lifeTime,
				\glitchFreq, 1.0.rrand(4.0),
				\pan, -0.8.rrand(0.8),
				\windowSize: 0.1.rrand(1.0),
				\overlaps: 0.1.rrand(10);
			]);

			// Wait a specific time before launching the next sound.
			// If we wait LESS than 'lifeTime', the sounds will overlap (crossfade).
			// If we wait MORE, there will be silence between them.
			(lifeTime * 1.0).wait; // 50% overlap (creates a lush, continuous pad).

		} {
			// If no buffer is found, wait a tiny bit and try again (safety check).
			0.1.wait;
		};
	}
}).play;
)