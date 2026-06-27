(
// --- 1. SETUP (Run this ONCE) ---
var folderPath = "/Users/oscarmontiel/Desktop/sonidos/poema-1-oam/adjetivos";

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
        arg bufnum, rate = 1.0, amp = 0.5, pan = 0.0, tremoloRate = 1.0, startPos = 0;
        var sig;
		var ampMod = SinOsc.kr(tremoloRate).range(0.1, 1.0);
        sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, startPos: startPos, doneAction: 2);

		sig = Pan2.ar(sig, pan, amp * ampMod);
        Out.ar(0, sig);
    }).add;

	("✅ SETUP COMPLETE. All " ++ ~buffers.size ++ " files loaded into ~buffers.").postln;
	~randomWait = 1.0;
	~ampTremoloMod = 1.0;

});
)

	~randomWait = 3.0;
	~ampTremoloMod = 20.0;

// --- 2. THE PLAYER (Run this AS MANY TIMES as you like!) ---
(
Tdef(\pianoPlayer, {
    loop {

        // Now we look for ~buffers (global), so it finds the files loaded in step 1
        var chosenBuf = ~buffers.choose;
		var playRate = [-1.0, 1.0].choose;
		var startPosition;
		~randomWait = 0.2.rrand(1.5);
		if(playRate < 0){
			startPosition = chosenBuf.numFrames - 2;
		}{
			startPosition = 0;
		};

        if(chosenBuf.notNil) {
            Synth(\player, [
                \bufnum, chosenBuf,
                // --- CHANGE THESE NUMBERS AND RE-RUN JUST THIS BLOCK ---
				\rate, playRate, // Pitch/Speed (try 0.5, 2.0, or -1.0)
                \amp, 0.3.rrand(0.6),
				\startPos, startPosition,
				\tremoloRate, 0.5.rrand(~ampTremoloMod),
				\pan, -1.0.rrand(1.0)
            ]);
        };

        // Change the speed of the rhythm here
		(0.1.rrand(~randomWait)).wait;
    }
}).play; // .play is here so it starts immediately when you update it
)


Tdef(\pianoPlayer).play;