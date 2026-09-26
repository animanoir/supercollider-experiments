s.boot;
s.plotTree;
s.freeAll;

(
~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
)
~pad1 = Buffer.read(s, ~soundDir +/+ "pg1.wav");
BufFrames.kr(~pad1).post;


t = TempoClock(130/60).permanent_(true);




(
SynthDef(\guitarString, { |freq = 440, amp = 1.0, gate = 1, decay = 12|
    var plectrum = PinkNoise.ar(0.6) * EnvGen.ar(Env.perc(0.001, 0.008), gate);
    var excitation = LPF.ar(plectrum, freq * Rand(1, 10));
    var string, pNoise;
    var envFreq = EnvGen.kr(Env.new(levels: [Rand(120, 440), 
      Rand(120, 440), 
      Rand(120, 440), 0], 
      times: [0.1, 0.5, 1], 
      curve: [-5, 0, -5]), doneAction: 2);
    var env = EnvGen.kr(Env.new(levels: [[0.0, 1.0].choose, 
      rrand(0.0, 1.0), 
      rrand(0.0, 1.0), 0], 
      times: [0.1, 0.5, 1], 
      curve: [-5, 0, -5]), doneAction: 2);
    var delay = (1 / freq);
    pNoise = PinkNoise.ar(1);
    string = Pluck.ar(excitation, gate, delay, delay, decay, coef: freq.linlin(80, 1000, 0.2, 0.6).clip(0.1, 0.7));
    string = BPF.ar(string, Rand(110, 510), 0.7, 0.3) + (string * Rand(0.1, 1.0));
    string = HPF.ar(string, 100);
    string = string.tanh;
    //string = string * SinOsc.ar(Rand(0.1, 3.0));
    DetectSilence.ar(string, amp: 0.001, time: 0.1, doneAction: 2);
    Out.ar(0, Pan2.ar(string, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), 100.0)));
}).add;
"guitarString added to server".post;
)





// GUI ---------------------------------------------------------

(
w = Window("MI MIDI PERSONAL", Rect(200, 200, 450, 180)).front;

StaticText(w, Rect(20, 20, 410, 30))
    .string_("¡WELKUM!")
    .font_(Font("Helvetica", 14, true))
    .align_(\center);

StaticText(w, Rect(20, 60, 410, 50))
.string_("Hy's:  Q  W  E  R  T  Y\nLows:  A  S  D  F  G  H  J  K")
    .font_(Font("Monaco", 11))
    .align_(\center);
)
// --------------------------------------------------------

//con octavas
(
w.view.keyDownAction = { |view, char|
    var freqMap = (
        // --- LOWS
        'a': 110.00, // La (A2) - Cuerda 5 de guitarra
        's': 130.81, // Do (C3)
        'd': 146.83, // Re (D3) - Cuerda 4 de guitarra
        'f': 164.81, // Mi (E3)
        'g': 196.00, // Sol (G3) - Cuerda 3 de guitarra
        'h': 220.00, // La (A3)
        'j': 246.94, // Si (B3) - Cuerda 2 de guitarra
        'k': 261.63, // Do Central (C4)

        // --- HIGHS
        'q': 293.66, // Re (D4)
        'w': 329.63, // Mi (E4) - Cuerda 1 de guitarra
        'e': 349.23, // Fa (F4)
        'r': 392.00, // Sol (G4)
        't': 440.00, // La (A4)
        'y': 493.88  // Si (B4)
    );

    if(freqMap[char.asSymbol].notNil) {

        Synth(\guitarString, [\freq, freqMap[char.asSymbol], \gate, 1]);
    };
};
)
