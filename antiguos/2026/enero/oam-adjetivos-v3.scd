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
	SynthDef(\player_experimental, {
		arg bufnum, baseRate = 1.0, amp = 0.5, pan = 0.0, tremoloRate = 1.0, startPos = 0;
		var sig, rateMod, localRate;

		// 1. EL "DEDO" QUE FRENA EL DISCO:
		// LFNoise1 genera valores aleatorios que se conectan mediante líneas rectas (rampas).
		// .kr(0.5) significa que cambia de objetivo cada 2 segundos aproximadamente.
		// .range(0.1, 0.5) lo mantiene en esa zona de "casi detenido".
		rateMod = LFNoise1.kr(0.5).range(0.1, 0.5);

		// 2. LA TASA FINAL:
		// Multiplicamos la base (1 o -1) por nuestra modulación aleatoria.
		localRate = baseRate * rateMod;

		// 3. REPRODUCCIÓN:
		sig = PlayBuf.ar(
			numChannels: 1,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * localRate,
			startPos: startPos,
			doneAction: 2
		);

		// Modulación de amplitud (tu tremolo original)
		sig = sig * SinOsc.kr(tremoloRate).range(0.1, 1.0);

		sig = Pan2.ar(sig, pan, amp);
		Out.ar(0, sig);
	}).add;

	("✅ SETUP COMPLETE. All " ++ ~buffers.size ++ " files loaded into ~buffers.").postln;
	~randomWait = 1.0;
	~ampTremoloMod = 1.0;

});
)

~randomWait = 3.0;
~ampTremoloMod = 50.0;

// --- 2. THE PLAYER (Run this AS MANY TIMES as you like!) ---
SynthDef(\player_experimental, {
    arg bufnum, baseRate = 1.0, amp = 0.5, pan = 0.0, tremoloRate = 1.0, startPos = 0;
    var sig, rateMod, localRate;

    // 1. EL "DEDO" QUE FRENA EL DISCO:
    // LFNoise1 genera valores aleatorios que se conectan mediante líneas rectas (rampas).
    // .kr(0.5) significa que cambia de objetivo cada 2 segundos aproximadamente.
    // .range(0.1, 0.5) lo mantiene en esa zona de "casi detenido".
    rateMod = LFNoise1.kr(0.5).range(0.1, 0.5);

    // 2. LA TASA FINAL:
    // Multiplicamos la base (1 o -1) por nuestra modulación aleatoria.
    localRate = baseRate * rateMod;

    // 3. REPRODUCCIÓN:
    sig = PlayBuf.ar(
        numChannels: 1,
        bufnum: bufnum,
        rate: BufRateScale.kr(bufnum) * localRate,
        startPos: startPos,
        doneAction: 2
    );

    // Modulación de amplitud (tu tremolo original)
    sig = sig * SinOsc.kr(tremoloRate).range(0.1, 1.0);

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(0, sig);
}).add;


Tdef(\pianoPlayer).play;