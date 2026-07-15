// HW2 - Making Sound, Part I

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW2.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// The following UGen function produces an error when we attempt to play it. Study the code and the error message, then correct the error and add a comment indicating what the problem was.

s.boot;

(
x = {
	var sig, freq, width;
	freq = LFSaw.ar(freq: 1/5, iphase: 1).exprange(200, 1500);
	freq2 = LFNoise0.ar(freq: 40 ! 2).range(1, 100);
	freq = (freq + freq2).round(50);
	width = LFTri.ar(freq: 0.2).exprange(0.02, 0.5);
	sig = VarSaw.ar(freq: freq, iphase: 0, width: width, mul: 0.05);
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 2.
// The following UGen function produces an error when we attempt to play it. Study the code and the error message, then correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, freq, amp;
	freq = LFNoise0.ar(freq: 9).exprange(40, 500);
	amp = LFSaw.ar(freq: 9, iphase: 1),range(0, 1).sqrt.neg + 1;
	sig = SinOsc.ar(freq: freq, mul: 0.2) * amp;
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 3.
// The following code does not produce an error, but fails to produce sound. Correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, noiseHz;
	noiseHz = LFNoise1.ar(freq: 10).exprange(500, 5000);
	sig = LFDNoise1.ar(freq: noiseHz, mul: 0.08);
	sig = sig * 0;
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 4.
// The following code does not produce an error, but fails to produce sound. Correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, phase: 3pi/2).range(0.02, 1);
	sig = PinkNoise.ar(0.2);
	sig = sig * mod;
	sig = sig ! 2;
}.play;
)

x.free;



// ----------
// Problem 5.
// Create and play a UGen function that emulates a police siren. You can use this video for reference:

// https://www.youtube.com/watch?v=1G9mNBUymP8

// You'll have to use your ears to figure out the right numbers. Using a periodic signal generator as a frequency modulator provides a rough solution, but using a looping envelope generator (e.g. Env.circle) allows more precision. It doesn't have to be identical to the sound in the video, but try to get as close as you can.




// ----------
// Problem 6.
// Copy, paste, and modify the code from the previous example in the following way: Add an argument that controls the rate at which the siren's pitch fluctuates, and add an amplitude envelope that allows the sound to be faded out gradually. In addition to code that plays the siren function, add at least one line of code that sets this parameter to a new value (running this line should make the siren pitch fluctuate faster or slower), and another line of code that slowly fades out the sound (as if the police car is driving away into the distance).




// ----------
// Problem 7.
// If you grew up with a landline phone in your house, or if you've watched classic horror movies, you may have heard the sound of a telephone that's been left off the hook for too long. It's kind of a disturbing sound: a periodic on-off pulsation of a harsh, mid-range tone. If you have no idea what I'm talking about, paste this link into your browser:

// https://www.youtube.com/watch?v=KO_YErq1M-M

// Create and play a UGen function that emulates this sound. From a spectral analysis perspective, I will tell you that it contains the following sinusoidal frequencies: [1400, 2060, 2450, 2600] Hz. The rest is up to you! Note: you can mix an array of multiple UGen signals down to a monophonic format using the array method 'sum'. Read ahead to Chapter 2.6 if you need extra help.





// ----------
// Problem 8.
// Copy, paste, and modify the code from the previous example so that the phone pulses now alternate between "normal" and one octave higher. The simplest way to do this is to incorporate a new UGen that operates as a frequecy multiplier, whose output values alternate between 1 and 2 at an appropriate rate.







