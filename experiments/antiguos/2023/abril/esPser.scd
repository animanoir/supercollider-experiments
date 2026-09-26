s.boot;
s.quit;

// Pser:
// Toca una secuencia de notas. El otro parámetro es un contador. Repite cuantas veces
// sea necesaria la secuencia y se detiene cuando el contador es 0.
(
Pbind(
 \note, Pser([0, Pseries(0,3,2), 3, Pseries(2,4,2)], inf),
	\dur, Pwhite(0.1,0.3),
 \amp, 0.5
 ).play;
)

(
Pbind(
 \note, Pser([0, Pseries(0,2,5), 5, Pseries(5,2,6), 3, 8, 11, 12], inf),
 \dur, 0.4,
 \amp, 0.5
 ).play;
)



//Pxrand:
// No vuelve a escoger el mismo valor 2 veces seguidas.
// Escoge un valor al azar el número de veces definido en el segundo parámetro.
(Pbind(
	\note, Pxrand([0,1,2,3,4],10),
	\dur, 0.2
).trace.play)

Pbind(\note, Prand([0,1,2,3,4], 10), \dur, 0.2).trace.play;

//Pshuf:
// Regresa y repite una secuencia con los valores reubicados en otro índice.
(Pbind(
	\note, Pshuf([0,1,2,3,4],10),
	\dur, 0.2
).trace.play)

//Pslide:
// Toma un valor y dependiendo de los parámetros hace saltos en la lista (con step) y así.
(Pbind(
	\note, Pslide([0,1,2,3,4],10,1,3,0, true),
	\dur, 0.2
).trace.play)

//Pseries:
// Toca una serie de notas.
// El primer parámetro es la nota inicial. El segundo los steps a saltar. El tercero las veces a tocar.
(Pbind(
	\note, Pseries(0,5,12),
	\dur, Pwhite(0.1,0.3),
	\amp, Pxrand([0.1,0.5],inf),
).trace.play)

//Pgeom:
// Como que crece o decrece exponencialmente.
(Pbind(
	\note, Pseq([0, Pn(2,3), Pn(2,3), Pn(5, 3), 7, Pn(8, 3), 11, 12],inf),
	\dur, Pgeom(0.1, 1.2, 12),
	\amp, Pxrand([0.1,0.5],inf),
).trace.play)


//Pn:
// Repetidamente embebe un patrón.
(Pbind(
	\note, Pseq([0, Pn(2,3), Pn(2,3)] ,inf),
	\dur, 0.2,
	\amp, Pxrand([0.1,0.5],inf),
).trace.play)



