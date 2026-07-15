// HW4 - Sampling

/*
This homework involves audio files in addition to SC code, so the submission process is slightly different. First, create a new folder on your computer named "Lastname HW4". Save this code file as "Lastname HW4.scd" inside this new folder. Then, download the following three audio samples and save them in a subfolder inside the main "Lastname HW4" folder you just created.

https://uofi.box.com/s/0756p9dspa8dhma4ecfovi7xo9mp2cpk

When you finish these problems, save your code file, then compress the entire "Lastname HW4" folder as a zip file (containing your code and subfolder of audio files), and upload the zip file as your assignment submission. An incomplete submission will result in deducted points.
*/

// ----------
// Problem 1.
// Write some code that reads these three audio files into buffers and stores the buffers in one or more environment variables. You can use an individual environment variable per buffer, or store all three in a singluar collection, like an array or event. The code should be written such that I can run your code on my computer and successfully load the audio files into buffers, without having to change any of your code or move files around. Use the 'play' method to confirm that your audio files have been successfully loaded.





// ----------
// Problem 2.
// Write a SynthDef that plays a buffer once, at its original playback rate. Make sure to account for the possibility that the sample rate of scsynth is different from the sample rate at which an audio file was created. Your SynthDef should only have one settable argument, corresponding to the bufnum of the buffer to be used. The Synth should free itself when it reaches the end of the sound file. Create three Synths (one for each buffer) to demonstrate functionality.





// ----------
// Problem 3.
// Repeat the previous problem, but if you used PlayBuf, use BufRd instead (and vice-versa).





// ----------
// Problem 4.
// Modify the SynthDef from Problem 2 by declaring additional arguments for playback rate and overall signal amplitude. Add a fixed-duration (non-gated) envelope that modulates overall signal amplitude, with settable arguments for attack, sustain, and release time. Deploy doneActions appropriately. Again, create several Synths (at least one for each of the three audio files) to show that all of your new arguments are functioning as expected.





// ----------
// Problem 5.
// Repeat the previous problem for the SynthDef you created in Problem 3.





// ----------
// Problem 6.
// Use an iteration method to create five Synths from the SynthDef you created in either of the two previous problems. Each Synth should play the desk bell sample at a unique playback rate, resulting in a five-voice chord. Make sure the amplitude of the overall sound doesn't clip above 0 dB (use s.meter to monitor output signal levels).





// ----------
// Problem 7.
/*
Review sections 4.4 and 4.4.1 of the course textbook. Create a new SynthDef based on the UGen function in Code Example 4.22 (p. 133), which combines RecordBuf and PlayBuf to produce a delay effect. You will first need to allocate a short buffer (see the first line of Code Example 4.18). The duration of the buffer determines the length of the delay. After creating the SynthDef, make the following modifications:

- Change the sound source to be PlayBuf instead of a randomly modulated SinOsc. You'll use this PlayBuf to play either the drumloop.wav or the mbdoor.wav sample when creating Synths later on. Set the 'loop' argument to 1 to enable looping playback.

- Change the 'preLevel' argument of RecordBuf to be a settable argument, expecting a value in decibels, instead of a fixed amplitude factor of 0.5. This decibel value should never be greater than zero (otherwise the sound will get progressively louder). Values close to zero (e.g. -1.dbamp) will have the result of siginficantly increasing the feedback character of the delay effect, and lower decibel values will cause the delay effect to decay more quickly.

- Use a sine LFO to modulate the playback rate of the PlayBuf you just created, and add two arguments: one for the rate of the LFO (measured in Hz), and another for the output range of the LFO (measured in semitones). Choose sensible default values for these arguments. This will produce a vibrato effect or modulation effects, depending on the specific values used.

- Add a sustaining, gated amplitude envelope with a settable gate, so that the overall sound can be faded out.

Then, create at least three Synths with a variety of argument values to demonstrate the different types of sounds that this SynthDef can make. Use the envelope gate argument to fade out each Synth you create.
*/





// ----------
// Problem 8.
// Create a new SynthDef that uses BufRd such that it behaves like a tone oscillator, by repeatedly reading through a small section of the mbdoor.wav file at a particular frequency. For BufRd's 'phase' input, a variety of oscillator UGens will work fine here. Include a settable 'freq' argument which determines the pitch of the sound produced. Also include a settable amplitude argument, and a gated amplitude envelope with settable attack and release parameters. Create at least two Synths with different frequencies to demonstrate functionality, and use their gate argument to fade them out.





