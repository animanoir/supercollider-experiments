s.options.sampleRate = 48000
s.boot;
s.exit;
s.makeWindow;

// Duda sobre nombramiento de variables: ¿Cómo nombrarlas correctamente?
// ¿El !2 es un "macro" universal para volver estéreo lo que sea? Lo vi aplicado dentro del rrand.
// Los sonidos, tras "volverse inaudibles", ¿se liberan en memoria?
// ¿Cómo secuenciar?
// ¿Qué driver es mejor usar?
// El .release libera paulatinamente un sonido.

({
	var sig;
	var panPositions = Array.series(10,-1.0,0.2);
	var sinPanPositions = Array.fill(10, { SinOsc.kr(rrand(0.1,5.0))});
	var darkFreqs = [82.41, 110.25, 147.83, 165.32, 220.91, 293.78, 311.13, 440.23, 493.92, 523.35];
	var etherealFreqs = [146.83, 220.00, 293.66, 349.23, 440.00, 523.25, 587.33, 698.46, 880.00, 1046.50];
	var amps = [0.7, 0.4, 0.9, 0.3, 0.8, 0.5, 0.2, 0.6, 0.35, 0.85];
	var env = EnvGen.ar(Env.perc(rrand(0.01, 1)), doneAction: rrand(0.1, 0.5));
	sig = SinOsc.ar(etherealFreqs, 0, sinPanPositions);
	sig = Pan2.ar(sig,panPositions.scramble);
	sig = sig * env;
	Mix.ar(sig);
	//sig = Splay.ar(sig, 0.3);
}.play
);


(
y = {
	arg gate=1;
	var thetaSpeed = 1.0;
	var theta = LFNoise0.kr(thetaSpeed).range(0.1, 10.0);
	var env, sig, modu, pan;
	//var sinPanPositions = Array.fill(2, { SinOsc.kr(rrand(0.1,5.0))});
	env = EnvGen.kr( Env.asr(1,1,3), gate);
	sig = Impulse.ar(SinOsc.kr(theta).range(1,5));

	sig = BPF.ar(sig, Array.series(100, 10, 100), 0.05);
	sig = Mix(sig);

	sig = CombC.ar(sig, 1, LFDNoise3.kr(theta).range(0.0,0.5));
	pan = Pan2.ar(sig, LFDNoise3.ar(theta).range(-1.0,1.0));
	sig = GVerb.ar(pan, 1.5, 100);
	sig * env;
}.play
)



(
y = {
	arg gate=1;
	var thetaSpeed = 1.0;
	var theta = LFNoise0.kr(thetaSpeed).range(0.1, 10.0);
	var env, sig, modu, pan;
	//var sinPanPositions = Array.fill(2, { SinOsc.kr(rrand(0.1,5.0))});
	env = EnvGen.kr( Env.asr(1,1,3), gate);
	sig = Impulse.ar(SinOsc.kr(theta).range(1,5));

	sig = BPF.ar(sig, Array.series(100, 10, 100), Array.rand(100, 0.0,0.05));
	sig = Mix(sig);

	sig = CombC.ar(sig, LFDNoise3.kr(theta).range(0.0,8.0), delaytime: LFDNoise3.kr(theta).range(0.0,5.0));
	pan = Pan2.ar(sig, LFDNoise0.ar(theta).range(-1.0,1.0));
	sig = GVerb.ar(pan, 1.5, 100);
	sig * env;
}.play
)

//sinPanPositions = Array.fill(2, { SinOsc.kr(rrand(0.1,5.0))})
(
y = {
	arg gate=1;
	var env, sig, modu, pan, theta = LFNoise0.kr(thetaSpeed).range(0.1, 10.0),thetaSpeed = 2.0;
	//var roomSizes = Array.rand(100, 1.0, 10.0); // Array de room sizes diferentes
	env = EnvGen.kr( Env.asr(1,1,LFDNoise0.kr(theta).range(1,5)), gate);
	sig = Impulse.ar(SinOsc.kr(theta).range(1,5));

	sig = BPF.ar(sig, Array.series(100, 10, rrand(100,800)), Array.rand(100, 0.0,0.05));

	sig = Mix(sig);

	sig = CombL.ar(sig, LFDNoise3.kr(theta).range(0.0,8.0), delaytime: LFDNoise3.kr(theta).range(0.0,3.0));
	pan = Pan2.ar(sig, LFDNoise3.ar(theta).range(-1.0,1.0));
	sig = GVerb.ar(pan, 5, 10);
	sig * env;
}.play
)


(
y = {
   arg gate=1;
   var env, sig, modu, pan, theta = LFNoise0.kr(thetaSpeed).range(0.1, 10.0), thetaSpeed = 2.0;
   var freqs = [110.0, 146.83, 164.81, 220.0, 293.66, 329.63, 440.0, 493.88, 587.33, 880.0]; // La menor oriental
   var trig = Dust.ar(theta); // Genera triggers aleatorios
   env = EnvGen.kr(Env.asr(1,1,LFDNoise0.kr(theta).range(1,5)), trig);
   sig = SinOsc.ar(
       freq: freqs, // Ligera desafinación
       mul: LFNoise1.kr(theta!10).range(0.1, 0.5)
   );
   sig = BPF.ar(sig, Array.series(100, 10, rrand(100,800)), Array.rand(100, 0.0,0.05));
   sig = Mix(sig);
   sig = CombL.ar(sig, LFDNoise3.kr(theta).range(0.0,1.0), delaytime: LFDNoise3.kr(theta).range(0.0,3.0));
   pan = Pan2.ar(sig, LFDNoise3.ar(theta).range(-1.0,1.0));
   sig = GVerb.ar(pan, 2, 10);
   sig * env;
}.play
)

(
y = {
   arg gate=1;
   var env, sig, modu, pan, theta = LFNoise0.kr(thetaSpeed).range(0.1, 10.0), thetaSpeed = 2.0;
   var freqs = [110.0, 146.83, 164.81, 220.0, 293.66, 329.63, 440.0, 493.88, 587.33, 880.0]; // La menor oriental
	var selectedFreq = Select.kr(LFNoise0.kr(theta).range(0, 9), freqs);
   env = EnvGen.kr(Env.perc, gate);
   sig = SinOsc.ar(
		freq: selectedFreq = Select.kr(LFNoise0.kr(theta).range(0, 9), freqs),
       mul: LFNoise1.kr(theta!10).range(0.1, 0.5)
   );
   sig = BPF.ar(sig, Array.series(100, 10, rrand(100,800)), Array.rand(100, 0.0,0.05));
   sig = Mix(sig);
   sig = CombL.ar(sig, LFDNoise3.kr(theta).range(0.0,1.0), delaytime: LFDNoise3.kr(theta).range(0.0,3.0));
   pan = Pan2.ar(sig, LFDNoise3.ar(theta).range(-1.0,1.0));
   sig = GVerb.ar(pan, 2, 10);
   sig * env;
}.play
)

// ----------------------------------------------

// melodía mariposa
(
y = {
   arg gate=1;
   var env, sig, modu, pan, theta = SinOsc.kr(thetaSpeed).range(0.1, 10.0), thetaSpeed = 2.0;
   var freqs = [110.0, 146.83, 164.81, 220.0, 293.66, 329.63, 440.0, 493.88, 587.33, 880.0]; // La menor oriental
   var trig = Impulse.ar(theta); // Genera triggers aleatorios
	var selectedFreq = Select.kr(LFNoise0.kr(theta).range(0, 9), freqs);
	env = EnvGen.kr(Env.perc);
   sig = SinOsc.ar(
       freq: selectedFreq * LFNoise1.kr(theta).range(0.99, 1.01), // Ligera desafinación
       mul: LFNoise1.kr(theta!10).range(0.1, 0.5)
   );
   //sig = BPF.ar(sig, Array.series(100, 10, rrand(100,800)), 0.01);
   //sig = Mix(sig);
   //sig = CombC.ar(sig, LFDNoise3.kr(theta).range(0.0,1.0)!2, delaytime: LFDNoise3.kr(theta).range(0.0,3.0));
   pan = Pan2.ar(sig, LFDNoise3.ar(theta).range(-1.0,1.0));
   //sig = GVerb.ar(pan, 0.5, 5);
   pan*env;
}.play
)