(Pbind(
 \degree, Pwhite(0.0, 3.0),
 \dur, Pwhite(0.01, 0.5),
 \amp, Prand([0.1, 0.1 ,0.2, 0.2, 0.3], inf),
 \legato, 0.1
).trace.play)

(Pbind(
 \degree, Prand([0, 1, 2, 3], inf),
 \dur, Prand([0.1, 0.21 ,0.2, 0.4, 0.5], inf),
 \amp, Prand([0.1, 0.1 ,0.2, 0.2, 0.3], inf),
 \legato, 0.1
).trace.play)

// Toca una secuencia de notas. El otro parámetro es un contador. Repite cuantas veces
// sea necesaria la secuencia y se detiene cuando el contador es 0.
(
Pbind(
 \note, Pser([12, 2, 3, 5, 3, 8, 11, 12], 10),
 \dur, 0.15;
 ).play;
)

s.boot;
s.quit;