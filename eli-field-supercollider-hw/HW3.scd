// HW3 - Making Sound, Part II

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW3.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// Use the 'plot' method to visualize exactly four complete cycles of a triangle wave whose frequency is 160 Hz.





// ----------
// Problem 2.
// Convert the following UGen function into a SynthDef. To demostrate functionality, add a line of code that creates a Synth, and another line of code that frees the Synth. Don't modify the UGen function any more than is necessary.

(
{
	var sig;
	sig = Pulse.ar(500) ! 2;
	sig = LPF.ar(sig, 2000);
	sig = sig * 0.2;
}.play;
)





// ----------
// Problem 3.
/*
Modify your SynthDef from the previous problem to have the following features:

- a settable frequency argument

- a settable amplitude argument

- an ADSR envelope that modulates signal amplitude, with a settable gate argument

To demostrate functionality, add at least two different lines of code that each create a Synth object with some custom-specified argument values. For each line of code that creates a Synth, include a corresponding line of code that fades the Synth using the gate argument (not a hard free).
*/





// ----------
// Problem 4.
/*
Modify the SynthDef from the previous problem to have the following features:

- an LFO that applies a vibrato effect with a musical appropriate width (± less than an equal-tempered semitone, but enough to be noticeable)

- a settable argument for the rate (i.e. frequency) of the LFO

- a settable argument that allows the vibrato effect to be bypassed. vibration should be present when this argument == 1, and absent when == 0.

Again, add at least two different Synth calls to demonstrate the behavior of the LFO with user-specified arguments. Add a third Synth call that demonstrates that the vibrato can be bypassed.
*/




// ----------
// Problem 5.
/*
The following UGen function, which plays a sum of five harmonically related sine waves, is written inefficiently (not in terms of CPU usage, but syntactically). Rewrite this code using an iteration method (either '.do' or '.collect') to more concisely express this line-by-line approach.
*/

(
{
	var sig;
	sig = SinOsc.ar(200);
	sig = sig + SinOsc.ar(800);
	sig = sig + SinOsc.ar(1400);
	sig = sig + SinOsc.ar(2000);
	sig = sig + SinOsc.ar(2600);
	sig = sig * 0.05 ! 2;
}.play;
)




// ----------
// Problem 6.
/*
Modify your code from the previous problem so that the amplitude of each sine wave is half as large relative to the sine wave immediately before it.
*/




// ----------
// Problem 7.
/*
Modify your code from the previous problem once more so that each sine wave has a unique "percussive" envelope (i.e., a two segment attack-decay envelope). The attack durations should all be very short (≤ 0.01 sec), but the decays should vary based on frequency — the lower the frequency, the longer the delay.
*/




// ----------
// Problem 8.
/*
In The Legend of Zelda: Ocarina of Time (N64, 1998), there is a sound effect that plays when Link collects a silver rupee in a puzzle room. An audio file and waveform image of the sound are downloadable here:

https://uofi.box.com/s/c72zyyt1rqlf8a2k3e6y65fvrbyf6vv3

Create and play a UGen function (not a SynthDef) that accurately emulates this sound, using a sine wave generator, an amplitude envelope, and a frequency envelope. You may find it helpful to view the audio file in a waveform editor, such as Audacity, to facilitate closer inspection. Don't ignore the decay transient near the end of the waveform that leads to a brief quieter steady-state, before fading out completely.

NOTE: in the image of the waveform, there is a "roughness" at moments where the pitch changes. This is most likely because, in the original game, the pitches overlap slightly, causing these interference patterns. Ignore this aspect of the sound in your emulation, and instead, code the frequency envelope as abrupt changes to be applied to a monophonic oscillator.
*/





// ----------
// Problem 9.
/*
Continuing from the previous problem: Also in the original video game, there are five silver rupees in a puzzle room. Each time Link collects an additional rupee, the pitch rises by an equal-tempered semitone (technically, the fifth rupee triggers the "puzzle solved" jingle, but we'll pretend it doesn't).

Convert the UGen function from the previous problem into a SynthDef, and then add a settable argument that represents the size of the pitch transposition, in semitones. The following five lines, when evaluated one-by-one, should play the silver rupee effect in ascending fashion.
*/





Synth(\silver, [semi: 0]);

Synth(\silver, [semi: 1]);

Synth(\silver, [semi: 2]);

Synth(\silver, [semi: 3]);

Synth(\silver, [semi: 4]);

// ----------
// Problem 10.
/*

Summer's not over yet! It's time to put on your bathing suit and run through a sprinkler. A particular type of sprinkler, in fact, which produces rapid-fire bursts of water for a few seconds, followed by slower bursts over a longer period of time. Then, this cycle repeats. Paste the following link into your browser to see an image of one of these sprinklers:

http://diy.sndimg.com/content/dam/images/diy/fullset/2014/2/24/0/RX-iStock-187558829_Water_Lawn_Sprinkler_h.jpg.rend.hgtvcom.616.462.suffix/1420798717602.jpeg

Here's a video of one of these sprinklers in action:

https://www.youtube.com/watch?v=-nA7kUgLykA

And, here's an audio file, produced in SC, which emulates the sound of this sprinkler.

https://uofi.box.com/s/vi5qb9h4yh2uv6mcn9dni7ienjj3p318

Create a SynthDef and generate a Synth that emulates this sound. White noise makes a good sound source, and LFPulse makes a good amplitude modulator for creating the noisy water bursts. You'll need another modulator to produce the behavior that alternates between fast and slow bursts.
*/





// -----------------------------------------
// Optional Bonus Problem (full credit = +3)
/*
Modify the SynthDef from the previous problem so that the sound is spatialized in stereo, and "moves" from left-to-right during the fast pulses, and right-to-left during the slow pulses. VarSaw is a good option for a pan position modulator, but this can also be done with EnvGen. Use Pan2 to pan the monophonic signal.
*/




