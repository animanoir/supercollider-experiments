(
// --- 1. SETUP (Run this ONCE) ---
var folderPath = "/Volumes/T7 Shield/sonidos/2026/enero/piano-glitch-1/";

s.waitForBoot({
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
        arg bufnum, rate = 1.0, amp = 0.5, pan = 0.0, tremoloRate = 1.0;
        var sig;
		var ampMod = SinOsc.kr(tremoloRate).range(0.1, 1.0);
        sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, doneAction: 2);

		sig = Pan2.ar(sig, pan, amp * ampMod);
        Out.ar(0, sig);
    }).add;

    "✅ SETUP COMPLETE. Files loaded into ~buffers.".postln;

});
)

	~randomWait = 2.0;
~ampTremoloMod = 10.0;

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
				\tremoloRate, 0.5.rrand(~ampTremoloMod),
				\pan, 0.0.rrand(-1.0, 1.0)
            ]);
        };

        // Change the speed of the rhythm here
		(0.125.rrand(~randomWait)).wait;
    }
}).play; // .play is here so it starts immediately when you update it
)


Tdef(\pianoPlayer).play;