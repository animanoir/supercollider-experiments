// Acordes
// Simplemente se pone en un arreglo los acordes.
(
Pbind(
	\note, Pseq([0, 3, 7], [2, 5, 8], [3, 8], [3, 7, 12], inf),
	\dur, 1.5,
	\ctranspose, 12,
	\amp, 0.5
 ).play;
)

(
Pbind(
	\note, Pseq([0, 3, 7, 2, 5, 8, 3, 7, 10, 5, 8, 12], inf),
	\dur, 1,
	\ctranspose, 12,
	\amp, 0.5
 ).play;
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
)



(
Pbind(
	\degree, Pseq([0, [1, 2], 3,5, [6, 4], 6, 7], inf),
	\dur, Pwhite(0.5, 0.3),
	\amp, 0.5,
	\strum, 0.01,
	\scale, Scale.yu,
 ).play;
)

Scale.directory.print;