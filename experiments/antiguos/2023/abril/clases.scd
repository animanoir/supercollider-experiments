// Duplica el el objeto n cantidad de veces.
"hello".dup(4);

// Redondea el valor.
3.1415.round(0.1); // note that the first dot is the decimal case of 3.1415
// Devuelve un valor al azar entre 0 y 100.
100.rand; // evaluate this line several times

// Podemos encadenar funciones/mensajes.
100.0.rand.round(0.01).dup(4);

// Ejercicio. Convertir esto a notación funcional.
100.0.rand.round(0.01).dup(4);
dup(round(rand(100.0),0.01),4);

// Nesting and proper indentation
(
{
	CombN.ar(
		SinOsc.ar(
			midicps(
				LFNoise1.ar(1, 1,
					LFSaw.ar([1, 5.123], 0, 3, 80)
				)
			),
			0, 0.1
		),
		1, 0.3, 10)
}.play;
)

s.boot;
s.quit;