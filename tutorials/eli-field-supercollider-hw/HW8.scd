// HW8 - Signal Processing and Order-of-Execution

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW5.scd"). Write your answers and upload this renamed file to the course website for your submission. If you use any audio files, make sure to include them in your submission as a zip file, and write your code appropriately (use 'resolveRelative' or 'thisProcess.nowExecutingPath').

// ----------
// Problem 1.
// Create and add three SynthDefs: The first should repeatedly rearticulate some sound source (a sine wave, a short sound file, etc.) with the application of a percussive amplitude envelope, the second should apply a feedback echo effect to an input signal (CombL is a good choice), and the third should apply reverb to an input signal (FreeVerb is a good choice). The delay SynthDef should have an argument that determines the delay time of the echo, and both the echo and reverb SynthDefs should have an argument that controls dry/wet balance. Add other arguments as needed. I strongly encourage you to build your SynthDefs from scratch (don't just copy and paste something from lecture)!





// ----------
// Problem 2.
// Write some code that creates three Synths on the server (one for each SynthDef) such that signal flows from the source synth, to the echo, and then to the reverb. Use Groups, Busses, etc. as needed to achieve the correct signal flow. There are different ways to achieve this — the only thing that matters is that the signal flow is correct.





// ----------
// Problem 3.
// Write some code that does nearly the same thing as the previous problem, but switches the order of the two processing effect Synths. Again, use Groups, Busses, etc. as needed to achieve the correct signal flow.





// ----------
// Problem 4.
// Write some code that creates three Synths on the server (one for each SynthDef) such that signal flows from the source to both effects, in parallel, rather than in series. You will likely need to make changes to your source SynthDef. The outputs from both processing effects should both be routed to hardware busses (where they will automatically be mixed together if using Out.ar).



