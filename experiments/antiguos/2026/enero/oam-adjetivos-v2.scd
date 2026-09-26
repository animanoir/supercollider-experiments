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
(
Tdef(\pianoPlayer, {
    // 1. PREPARACIÓN (Fuera del loop)
    var deckDeBuffers = Pshuf(~buffers, inf).asStream;

    loop {
        // --- ZONA DE VARIABLES (Siempre arriba) ---
        var chosenBuf = deckDeBuffers.next;
        var playRate = [-1.0, 1.0].choose;
        var startPosition = 0; // Valor por defecto
        var tiempoEspera = 0.2.rrand(2.0); // Usamos var local mejor que global ~

        // --- ZONA DE SEGURIDAD ---
        // Solo entramos aquí si REALMENTE tenemos un buffer en la mano
        if(chosenBuf.notNil) {

            // A. Lógica de reversa (Ahora es seguro preguntar por .numFrames)
            if(playRate < 0){
                startPosition = chosenBuf.numFrames - 2;
            };

            // B. Imprimir en consola (Ahora es seguro preguntar por .fileName)
            //("Reproduciendo: " ++ chosenBuf.fileName).postln;

            // C. Hacer sonido
            Synth(\player, [
                \bufnum, chosenBuf,
                \rate, 1,
                \amp, 0.3.rrand(0.6),
                \startPos, startPosition,
                \tremoloRate, 0.5.rrand(~ampTremoloMod),
                \pan, -1.0.rrand(1.0)
            ]);

            // D. Esperar
            // Esperamos solo si tocamos algo.
            (0.1.rrand(tiempoEspera)).wait;

        } {
            // Si salió nil (error de carga), esperamos un poco para no congelar la compu
            0.1.wait;
        };
    }
}).play;
)


Tdef(\pianoPlayer).play;