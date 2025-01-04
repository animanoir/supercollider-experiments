// Esto es un comentario.
/* Estos es
un comentario multínea
*/

// Los () sirven para agrupar código.
(
{SinOsc.ar(mul: 0.5)}.play;
)


4
"Texto"
4.sqrt
[0,1,2,3]


// Los UGENS son como las clases que tienen argumentos.
{SinOsc.ar(220,0,1)}.play
// .ar quiere decir "audio rate"/argumentos.
// .kr es "kontrol rate".
// Parciales infinitas (múltiplos infinitos de una frecuencia base)
// El pensamiento tras SC, o todo el audio digital, es que estamos trabajando con funciones matemáticas.
// ¿Todo está normalizado entre -1. 1.?
s.boot;