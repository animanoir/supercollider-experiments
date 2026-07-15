// HW6 - Patterns

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW6.scd"). Write your answers and upload this renamed file to the course website when ready to submit.

// ----------
// Problem 1.
// In the previous assignment, you created a Routine that returned incrementally increasing multiples of five, producing the values 0, 5, 10, etc., indefinitely. Use a pattern to achieve the same thing. Convert your pattern to a stream and use 'next' to demonstrate.





// ----------
// Problem 2.
// Similar to what you did in the previous assignment, modify the pattern from the previous problem so that it returns increasing multiples of five from 0 to 40, then decreasing multiples of eight back down to 0. The output should produce the following sequence, repeated indefinitely: 0, 5, 10, 15, 20, 25, 30, 35, 40, 32, 24, 16, 8. Don't just dump these values into a single Pseq. Instead, demonstrate your understanding of composite patterns by using a combination of at least two different pattern objects.





// ----------
// Problem 3.
// Create a composite pattern that starts at zero and applies an additive increment that is initially 1 and increases by 1 after each output. The sequence should be 0, 1, 3, 6, 10, 15, 21, etc. Convert the pattern to a stream and use 'next' to demonstrate.





// ----------
// Problem 4.
// Create a pattern that defines an infinite-length stream that outputs the number 60 approximately 85% of the time, the number 67 approximately 10% of the time, and the number 70 approximately 5% of the time. Convert the pattern to a stream and use 'nextN' to extract an array of 50 values at once. This can be done using a single pattern object (and there is an obvious choice of which pattern to use).





// ----------
// Problem 5.
// Using a pattern or combination of patterns, create an infinite-length stream that randomly outputs one of the following three things: (1) The number 1, once, (2) the number 0.5, twice in a row, or (3) the number 0.25, four times in a row. Each of these three possibilities should have an equal probability of occurring, but the the same outcome should never occur twice in a row. Convert the pattern to a stream and use 'nextN' to extract an array of 50 values at once.





// ----------
// Problem 6.
// Create a pattern that defines a sequence that starts at 0.5 and is reduced by half 5 times in a row, and then reverses direction and goes back up to 0.5. The sequence should be the following values, repeated indefinitely: 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/32, 1/16, 1/8, 1/4, repeated indefinity (the actual results don't need to be fractions, decimal expression is fine). Again, don't just use a single Pseq. Instead, use a combination of patterns. Convert the pattern to a stream and use 'next' to demonstrate.





// ----------
// Problem 7.
// Create a pattern that outputs prime numbers in ascending fashion. Convert the pattern to a stream and use 'next' to demonstrate. Remember that, with few exceptions, methods that can be applied to numbers and collections are also valid for Patterns. There are several ways to do this, but all of them will likely involve the Integer method 'isPrime'. Convert the pattern to a stream and use 'next' to demonstrate.





// ----------
// Problem 8.
// Create a infinite-length Pbind that uses the pattern from Problem 4 as values for the \midinote key, values from Problem 5 for the \dur key, and values from Problem 6 as the \amp key.

// Create your own SynthDef and use it for the \instrument key of this Pbind. Your SynthDef must include an argument named 'freq' for pitch information, and an argument named 'amp' for overall amplitude. Your SynthDef should also include a gated, sustaining envelope (Env.adsr, for example) and your gate argument must be named 'gate'. Play your Pbind, storing the result in a new variable, and include a 'stop' command that stops playback.

// Play the pattern on a clock running at 136 bpm, and set either the \sustain or \legato key (and, if necessary, your envelope attack/decay/release parameters) to produce short notes.





// ----------
// Problem 9.
// Modify the Pbind from the previous problem in the following way: Use \degree instead of \midinote, and replace its corresponding value pattern with a new pattern that achieves the exact same musical result. You will either need to supply an appropriate \scale in the Pbind, or use 's' or 'b' to sharp or flat your degree values (2b is flat scale degree 2, 3s is sharp scale degree 3, etc). Also, use \db instead of \amp, and replace its corresponding pattern with a new value pattern that achieves the exact same musical result. An amp value of 0.5 is equal to -6 dB, 0.25 is -12 dB, 0.125 is -18, etc. Again, 'play' the Pbind and also call 'stop' on the resulting EventStreamPlayer to demonstrate functionality.





// ----------
// Problem 10.
// Modify the Pbind from the previous problem in the following way: Provide a pattern for the \type key (adding it if not already present) so that approximately 1/5th of all events are rests instead of notes.





// ----------
// Problem 11.
// Modify the Pbind from the previous problem so that, when played, it lasts exactly 16 beats, instead of continuing indefinitely (see Pfindur).





// ----------
// Problem 12 (optional extra credit, worth +3).
// Create two additional musical variations on your Pbind from the previous problem. Create and play these variations in sequence, using Pseq, and also create and play a version in which all three variations play simultaneously, using Ppar.





