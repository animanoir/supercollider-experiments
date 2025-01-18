s.boot;
s.makeWindow;

// Duda sobre nombramiento de variables: ¿Cómo nombrarles correctamente?
// ¿El !2 es un "macro" universal para volver estéreo lo que sea? Lo vi aplicado dentro del rrand.

({
	var sig;
	var panPositions = Array.series(10,-1.0,0.2);
	var darkFreqs = [82.41, 110.25, 147.83, 165.32, 220.91, 293.78, 311.13, 440.23, 493.92, 523.35];
	var amps = [0.7, 0.4, 0.9, 0.3, 0.8, 0.5, 0.2, 0.6, 0.35, 0.85];
	var env = EnvGen.ar(Env.perc(rrand(0.01, 2)), doneAction: rrand(0.1, 2));
	sig = SinOsc.ar(darkFreqs, 0, amps.scramble);
	sig = Pan2.ar(sig,panPositions.scramble);
	sig = sig * env;
	Mix.ar(sig);
	//sig = Splay.ar(sig, 0.3);
}.play
);