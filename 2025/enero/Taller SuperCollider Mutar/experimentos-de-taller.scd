s.boot;
s.makeWindow;



({
	var sig;
	var darkFreqs = [82.41, 110.25, 147.83, 165.32, 220.91, 293.78, 311.13, 440.23, 493.92, 523.35];
	var amps = [0.7, 0.4, 0.9, 0.3, 0.8, 0.5, 0.2, 0.6, 0.35, 0.85];
	sig = SinOsc.ar(darkFreqs, 0, amps.scramble);
	sig = Splay.ar(sig, 0.3);
}.play
);