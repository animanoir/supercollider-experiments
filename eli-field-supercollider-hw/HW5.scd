// HW5 - Routine and TempoClock

/*
Like the previous homework, this assignment involves audio files in addition to SC code, so make sure to submit your work correctly. As you did before, you'll first create a new folder on your computer named "Lastname HW5". Save this code file as "Lastname HW5.scd" inside this new folder. If a problem instructs you to download audio files, make sure to save them in this same folder. When you are ready to submit, save your code file, then compress the entire "Lastname HW5" folder as a zip file (containing your code and subfolder of audio files), and upload the zip file as your assignment submission. An incomplete submission will result in deducted points.

Keep in mind that this HW assignment reinforces concepts related to Routine and TempoClock. Even though we may have started discussing Pbind in class at this point, you should not be using Pbind in this assignment.
*/

// ----------
// Problem 1.
// Create a Routine that returns multiples of five in ascending fashion, starting at zero. Your Routine should produce the values 0, 5, 10, etc., and continue indefinitely. On a separate line, use 'next' to demonstrate your Routine.





// ----------
// Problem 2.
// Modify the Routine from the previous problem so that it returns increasing multiples of five from 0 to 40, then decreasing multiples of eight from 40 to 0. The output should produce the following sequence, repeated indefinitely: 0, 5, 10, 15, 20, 25, 30, 35, 40, 32, 24, 16, 8. Don't simply pre-fill an array with these values and 'yield' them one-by-one. Instead, try to find a more efficient approach — one that could theoretically be deployed efficiently even if the repeated sequence was extremely long. On a separate line, use 'next' to demonstrate your Routine.





// ----------
// Problem 3.
// Using the SynthDef provided, create a Routine which, when played, produces an infinite sequence of Synths, using the number-generating Routine from the previous problem to provide frequency values to your created Synths. Treat these numerical values as MIDI note numbers, shifted up so that the sequence begins on note number 45 instead of 0. Tempo and timing are at your discretion. Don't forget to 'wait' in between Synths, otherwise you will probably crash the software!

(
SynthDef(\tone, {
	var sig, lpf, env, freq = \freq.ir(440);

	// fixed-duration ADSR-style amplitude envelope
	env = EnvGen.ar(
		Env([0, 1, 0.5, 0.5, 0], [0.005, 0.05, \sus.ir(1), 0.2], -1 ! 4),
		doneAction: 2
	);

	// envelope for lowpass filter cutoff frequency
	// (expressed as a harmonic multiple of oscillator frequency)
	lpf = EnvGen.ar(Env([1.8, 0.7], [0.2], [-4]));
	lpf = (lpf * freq).clip(20, 20000);

	sig = Pulse.ar(
		freq: freq * {Rand(-0.1, 0.1).midiratio}.dup(5),
		width: 0.1
	);
	sig = Splay.ar(sig);
	sig = LPF.ar(sig, lpf);
	sig = sig * env * 0.2;

	Out.ar(0, sig);
}).add;
)





// ----------
// Problem 4.
// Rewrite the Synth-generating Routine from the previous problem so that SC plays the Synths as eighth notes at a tempo of 84 bpm. Use TempoClock to achieve correct timing.





// ----------
// Problem 5.
// Rewrite the code from the previous problem so that the sequence of pitches can start at an arbitrary transposition, instead of always starting on 45. Then, create two Synth-generating routines that start on two different pitches. Write a line of code that plays the first Routine, and a separate line of code that plays the second Routine. The two routines should be quantized so that the eighth notes line up (the phase difference between the two Routines doesn't matter, as long as the eighth notes are aligned). Each Synth-generating Routine should be using its own, independent note-generating Routine (they should not be "sharing" the same Routine, which will result in the sequences being interleaved and twice as short).





// ----------
// Problem 6.
// Listen to the first four measures of 'Accede' by Carbon Based Lifeforms:

// https://www.youtube.com/watch?v=yYJ_Y02GP6M

// Write and play a Routine that produces this melodic four-bar phrase, repeated indefinitely. Listen carefully and try to specify the correct pitches and rhythms. Use the SynthDef provided or create your own. Your Routine should match the tempo of the song, which is 95 bpm. You may want to create separate Routines for note number generation, duration generation, and Synth generation, but you can complete this problem in whatever way seems most straightforward to you, as long as it uses Routine and TempoClock. For reference, here is a link to an audio recording of my version:

// https://uofi.box.com/s/359fweaz5is2q19yfghytx7l1fm2hejc





// ----------
// Problem 7.
// Download the kick, snare, and hi-hat files provided at the following link:

// https://uofi.box.com/s/98isi8111w1ojz0v6qaxezmuhlif96t0

// Read these files into three different buffers. Remember to code and submit appropriately — I should be able to run your code successfully without changing any code or having to move files around. Then, create and play a Routine that produces a simple house beat, indefinitely: kick drum on all four quarter notes, snare on beats 2 and 4, and sixteeth notes for the hi-hat. Build and use a basic sampling SynthDef to generate your Synths. Use a TempoClock running at a tempo within the general range of house music (approx. 115-130 bpm).

// You may notice a small but barely noticeable amount of timing "jitter" when you play your Routine. This is to be expected if certain precautions are not taken. When using SC's pattern library (e.g., Pbind), issues with slightly imprecise timing are handled and resolved automatically.





// -----------------------------------------
// Optional Bonus Problem (full credit = +3)
// Modify the Routine from the previous problem so that every measure of 4/4 is randomly selected from a collection of several different options. One option will be the simple house beat you already created. Include at least two other one-measure variations (e.g., some sort of drum fill) that can be randomly selected.