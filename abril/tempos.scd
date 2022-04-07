(
	Pbind(
	\degree, Pseq([0, 0.1, 1, Rest(0), 3, 4, 5, 6, 7]),
		\dur, 1,
	\amp, 0.5;
).trace.play(TempoClock(140/60)); // 120 beats over 60 seconds: 120 BPM
)

(
Pbind(
	\degree, Pseq([[0, 3, 7], [2, 5, 8], [3, 7, 10], [5, 8, 12]], inf),
	\scale, Scale.yu,
	\ctranspose, -12,
	\dur, 0.5,
	\amp, 0.5,
	\strum, Pwhite(0.1, 0.5) // Espacio en tiempo entre las notas tocadas en un acorde.
 ).play;
Pbind(
	\degree, Pseq([0, [1, 2], 3,5, [6, 4], 6, 7], inf),
	\dur, Pwhite(0.5, 0.3),
	\amp, 0.5,
	\strum, 0.01,
	\scale, Scale.yu,
).play;
)

// Fork, o para disparar eventos en orden.
({
	"one thing".postln;
	2.wait;
	"another thing".postln;
	1.5.wait;
	"one last thing".postln;
}.fork;)


// Iniciar o detener una secuencia Pbind:
(
~firstSectionScore = Pbind(
	\note, Pseq([0, 3, 7, 2, 5, 8, 3, 7, 10, 5, 8, 12], inf),
	\dur, 1,
	\ctranspose, 12,
	\amp, 0.5
 );
)

~player1 = ~firstSectionScore.play;

~player1.stop;
~player1.resume;
~player1.start;
~player1.reset;


~notasChidas = [1 ,2 ,3 ,4 ,5 ,6];

Pbind(\note, Pseq(~notasChidas, 1), \dur, 0.15).play;
Pbind(\note, Prand(~notasChidas, 6), \dur, 0.15).play;
Pbind(\note, Pslide(~notasChidas, 5, 3, 1), \dur, 0.15).play;