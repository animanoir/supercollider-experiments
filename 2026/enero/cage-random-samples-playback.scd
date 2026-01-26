(
// --- 1. SETUP (Run this ONCE) ---
var folderPath = "/Users/oscarmontiel/Desktop/sonidos/john-cage/Cage Soft Pedal ST/";

s.waitForBoot({
    // NOTICE: We removed 'var buffers' and now use '~buffers'
    var pathObj, soundFiles;

    pathObj = PathName(folderPath);
    soundFiles = pathObj.entries.select({ |file|
        file.extension.toLower == "wav"
    });

    // We store the result in a global variable (~)
    ~buffers = soundFiles.collect({ |file|
        Buffer.read(s, file.fullPath);
    });

    s.sync;

    // --- INSTRUMENT DEFINITION ---
    SynthDef(\player, {
        arg bufnum, rate = 1.0, amp = 0.5, pan = 0.0;
        var sig, left, right;
        sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, doneAction: 2);
		left = sig[0];
		right = sig[1];
		sig = Balance2.ar(left, right, pan, amp);
        Out.ar(0, sig);
    }).add;

    "✅ SETUP COMPLETE. Files loaded into ~buffers.".postln;
});
)

// --- 2. THE PLAYER (Run this AS MANY TIMES as you like!) ---
(
Tdef(\pianoPlayer, {
    loop {
        // Now we look for ~buffers (global), so it finds the files loaded in step 1
        var chosenBuf = ~buffers.choose;

        if(chosenBuf.notNil) {
            Synth(\player, [
                \bufnum, chosenBuf,

                // --- CHANGE THESE NUMBERS AND RE-RUN JUST THIS BLOCK ---
                \rate, 1.0,           // Pitch/Speed (try 0.5, 2.0, or -1.0)
                \amp, 0.3.rrand(0.6),
                \pan, 0.8.rand2
            ]);
        };

        // Change the speed of the rhythm here
		(0.125.rrand(0.1)).wait;
    }
}).play; // .play is here so it starts immediately when you update it
)

Tdef(\pianoPlayer).play;