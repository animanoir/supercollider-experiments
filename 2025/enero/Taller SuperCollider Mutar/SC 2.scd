//SC sesión 2

/*
En la clase de hoy veremos:

Arrays, parte 2. Métodos y operaciones.

Generadores de números aleatorios

.midicps y .cpsmidi

Array.fill

Envolventes. Env y EnvGen

Synth y SynthDef. Cómo definir y establecer un sintetizador

Rutinas (introducción)

*/


s.boot;
s.makeWindow;



//Métodos con Arrays
x =[10, 20, 30, 40, 50];

//.scramble desordena los elementos del array
x.scramble

//.mirror crea un array que espeja los valores del array original
x.mirror

//.choose elige al azar un elemento del array
x.choose

//.wchoose elige con un índice de probabilidad. El porcentaje de probabilidad debe ser indicado en un array (un valor por cada elemento) y en total deben sumar 1
x.wchoose([0.1, 0.1, 0.1, 0.2, 0.5]);

//Si volvemos a evaluar nuestra variable veremos que nuestro array original está intacto
x.value

//Para que las operaciones sobre nuestro array se queden guardadas debemos almacenarla en la misma variable o en otra distinta
x = x.scramble
x.value;
y = x.mirror
y.value

//Ejemplo de una función. Cada vez que evaluemos esta función el resultado tímbrico será distinto. Al utilizar el método .scramble para el array de amplitudes tendremos cada vez una amplitud distinta para cada una de las frecuencias de nuestro SinOsc.

(
{
	var sig, freqs, amps;

	amps = [ 0.05, 0.05, 0.1, 0.3, 0.5];

	freqs = [100, 205, 310, 415, 520];

	sig = SinOsc.ar(freqs, 0, amps.scramble);

	sig = Splay.ar(sig, 0.3);

}.play
);




//Generadores de números aleatorios

//rrand es un método que genera valores aleatorios con un tipo de distribución lineal, todos los valores tienen la misma probabilidad de salir
rrand(0, 20);

//Si queremos valores decimales con rrand debemos indicar al menos uno de los dos valores como decimal
rrand(0, 20.0);
rrand(0, 20.0).round(0.01); //Para redondear los valores a la cantidad de decimales que más nos resulte conveniente

//exprand genera valores aleatorios con una progresión exponencial, es decir que tendrán más posibilidades de salir los valores más bajos. Da por defecto valores decimales. IMPORTANTE, las curvas exponenciales en SuperCollider no pueden llegar al cero ni atravesarlo. Debemos utilizar valores decimales cercanos, 0.0001
exprand(0, 1000); //da error
exprand(0.001, 1000);




/*Notas MIDI con .midicps y .cpsmidi
El método .midicps permite convertir un número en frecuencia, de acuerdo a la frecuencia que tendría ese número de nota MIDI.
El protocolo MIDI utiliza 128 valores para las notas musicales temperadas, desde la nota 0 (Do-1) hasta la nota 127 (Sol9).
Los pianos suelen ir desde la nota MIDI 21 (La0) hasta la nota 108 (Do8).
*/

45.midicps //La2 a 110Hz
57.midicps //La3 a 220Hz
69.midicps //La4 a 440Hz

60.midicps //Do4, Do central del piano en nota midi
61.midicps //Do sostenido4 / Re bemol4
62.midicps //Re4
63.midicps //Re sostenido4 / Mi bemol4
64.midicps //Mi4
65.midicps //Fa4
66.midicps //Fa sostenido4 / Sol bemol4
67.midicps //Sol4
68.midicps //Sol sostenido4 / La bemol4
69.midicps //La4
70.midicps //La sostenido4 / Si bemol 4
71.midicps //Si4
72.midicps //Do5

//.cpsmidi realiza la operación inversa. le proporcionamos una frecuencia y nos indica el número de nota MIDI
440.cpsmidi
220.cpsmidi
523.25.cpsmidi.round(1)




//Cada vez que evaluemos esta función el oscilador tendrá un valor de frecuencia distinto, elegido entre los doce semitonos de la octava central del piano

x = {SinOsc.ar( rrand(60, 72).midicps, 0, 0.5)!2}.play
x.release(1)

//Recuerdan que había una diferencia si colocábamos !2 fuera de los argumentos de nuestras UGens y métodos o si lo hacíamos dentro? Observemos qué ocurre si lo colocamos dentro de los argumentos del rrand. Evalúa dos veces

y = {SinOsc.ar( rrand(60, 72!2).midicps, 0, 0.5)}.play
y.release(1)


/*Array.fill
El método .fill aplicado a la clase Array nos permite crear Arrays con funciones. Array.fill necesita dos aargumentos, primero la cantidad, y luego la función a crear.
Es especialmente útil para crear texturas densas con mucha complejidad y emplear métodos de aleatoriedad.
*/

x = Array.fill( 50, {rrand(0, 100)});

//En el siguiente ejemplo Array.fill crea un Array con 50 SinOsc, cada uno con su frecuencia. Luego este Array de 50 elementos es distribuido en el campo stereo gracias a Splay.
//versión 1
(
{
	var sig;
	sig = Array.fill( 50, {
		SinOsc.ar( rrand(20, 10000), 0, 1/50)});
	sig = Splay.ar(sig, 1);
}.play
);

//versión 2
(
{
	var sig;
	sig = Array.fill( 50, {
		SinOsc.ar( rrand(20, 10000), 0, rrand(1/200,1/20))}); //En este caso la amplitud también de cada frecuencia también será definida aleatoriamente
	sig = Splay.ar(sig, 1);
}.play
);

//versión 3, utilizando exprand para tener una distribución más cercana a las frecuencias graves
(
{
	var sig;
	sig = Array.fill( 50, {
		SinOsc.ar( exprand(20, 10000), 0, rrand(1/200,1/20))});
	sig = Splay.ar(sig, 1);
}.play
);

//Versión 4, vamos a panoramizar dando a cada SinOsc una trayectoria distinta en el campo stereo
(
{
	var sig;
	sig = Mix(
		Array.fill( 50, {
		Pan2.ar(
				SinOsc.ar( exprand(20, 10000), 0, rrand(1/200,1/20)),
				SinOsc.kr(rrand(0.1, 1))
			)
		});
	)
}.play
);

//Si limpiamos el código anterior vamos a ver que estamos creando 50 versiones de esta función:
(
{
	Pan2.ar(
		SinOsc.ar( exprand(20, 10000), 0, rrand(1/200, 1/20)),
		SinOsc.kr(rrand(0.1, 1))
)
}.play
);




/*
Envolventes
Una envolvente es una curva de valores que tiene principio y fin. Son aplicadas usualmente para valores de amplitud pero pueden aplicarse a cualquier parámetro del sonido.
En SuperCollider las envolventes se pueden implementar utilizando las UGens EnvGen y Env.
Luego tenemos envolventes simples como Line y XLine, que realizan una progresion de valores en un tiempo indicado
*/


//EnvGen es una UGen compleja, es un generador de envolventes. Su primer argumento es la envolvente que va a implementar (Env).
//Env a su vez tiene su serie de argumentos, primero un array con los valores a los que va a llegar, y su segundo argumento es el de los tiempos que tardará en llegar de un punto a otro.


//En este ejemplo vemos como la envolvente va de 0  a 1 en 0.5 segundos, de 1 a 0.5 en 0.5, se sostiend en 0.5 durante 1 segundo, y luego vuelve a 0 en 1 segundo
(
{EnvGen.kr( Env([0, 1, 0.5, 0.5, 0], [0.5, 0.5, 1, 1]))}.plot(3)
)

//Env puede contener otro Array indicando el tipo de curva que se desea para ir de un punto a otro. Por default está establecido \lin, es decir lineal. Podemos poner números positivos o negativos para modificar el tipo de curva
(
{EnvGen.kr( Env([0, 1, 0.5, 0.5, 0], [0.5, 0.5, 1, 1], [4, -2, 3, 10]))}.plot(3)
)

//La misma envolvente con todos números positivos en sus curvas se mantiene más cerca del primer valor, y luego se acerca más abruptamente al valor de destino
(
{EnvGen.kr( Env([0, 1, 0.5, 0.5, 0], [0.5, 0.5, 1, 1], [5, 5, 5, 5]))}.plot(3)
)

//La misma envolvente con todos números negativos, realiza lo opuesto. Avanza rápidamente al valor de destino y luego tiene una llegada más suave
(
{EnvGen.kr( Env([0, 1, 0.5, 0.5, 0], [0.5, 0.5, 1, 1], [-5, -5, -5, -5]))}.plot(3)
)


//No temer! Hay maneras de establecer envolventes con más rapidez.

//Env.perc
(
{EnvGen.kr( Env.perc)}.plot(1) //Envolvente percusiva
);

(
{
	var sig, amp;

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.perc);

	sig = sig * amp;

}.play
)

//Env.sine
(
{EnvGen.kr( Env.sine)}.plot(1) //Envolvente senoidal
);

(
{
	var sig, amp;

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.sine);

	sig = sig * amp;

}.play
)

//Env.triangle
(
{EnvGen.kr( Env.triangle)}.plot(1) //Envolvente triangular
);

(
{
	var sig, amp;

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.triangle);

	sig = sig * amp;

}.play
)


//Tener cuidado con la acumulación de sintetizadores en el servidor. doneAction es un argumento de EnvGen e indica qué es lo que hará el servidor con nuestro sintetizador una vez que haya terminado la envolvente. doneAction 0 no tomará acción y dejará el sintetizador activo. doneAction 2 le pedirá al servidor que una vez terminada la envolvente elimine el sintetizador del servidor. Por default EnvGen tiene un doneAction con valor 0

//Si queremos que no se acumulen sintetizadores en el servidor podemos indicar doneAction 2
(
{
	var sig, amp;

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.perc, doneAction:2);

	sig = sig * amp;

}.play
)


//Argumento gate de EnvGen
//Gate actúa como trigger de nuestra envolvente, cuando el valor es 1 se activará, cuando sea 0 estará inactiva. Para este tipo de códigos el valor de doneAction debe ser 0.



//Impulse da una serie de pulsos equidistantes. Esta UGen genera una muestra única con valor 1 que actúa como impulso
(
{
	var sig, amp, trigger;

	trigger = Impulse.kr(1);

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.perc, trigger);

	sig = sig * amp;

}.play
)

//Dust genera pulsos a un ritmo aleatorio y desordenado, el valor de frecuencia indica la cantidad de pulsos que habrá por segundo en promedio
(
{
	var sig, amp, trigger;

	trigger = Dust.kr(1);

	sig = SinOsc.ar(220)!2;

	amp = EnvGen.kr( Env.perc, trigger);

	sig = sig * amp;

}.play
)




/*Synth y SynthDef
Existe una manera de enviar una función al servidor y que quede almacenada con un nombre único y es a través de la clase SynthDef. SynthDef lo que nos ayuda es a proporcionar un nombre y una función, con nuestras variables y argumentos para que luego pueda ser más fácil y flexible manejarlos.
SynthDef necesita siempre como última línea de su código la UGen Out que indicará por qué canal saldrá nuestra señal, y luego la señal que enviaremos a través de ese canal.
Synth es la clase que llama a ese sintetizador por su nombre en el servidor, y proporciona los argumentos a través de un array de pares de símbolos y valores.
*/


(
SynthDef.new( \ping, {
	arg note=72, amp=0.1;
	var sig, env;

	sig = SinOsc.ar(note.midicps)!2;

	env = EnvGen.ar(Env.perc, doneAction:2);

	Out.ar(0, sig * env * amp)
}
).add
);


Synth(\ping, [\note, rrand(50, 80), \amp, rrand(0.1, 0.3)]);


(
SynthDef.new( \saw, {
	arg note=72, amp=0.1;
	var sig, env;

	sig = Saw.ar(note.midicps)!2;

	sig = LPF.ar( sig, note.midicps * 2);

	env = EnvGen.ar(Env.perc, doneAction:2);

	Out.ar(0, sig * env * amp)
}
).add
);

Synth(\saw, [\note, exprand(50, 80).round(1), \amp, rrand(0.1, 0.3)]);




/*Rutinas (intro)
Las son clases que permites realizar procesos de repetición, iteración y automatización.
Se suelen implementar con el método .do que evalúa una función un número determinado de veces
*/

//Ejemplo 1
(
r = Routine.new({
	5.do({
		Synth(\saw, [\note, rrand(50, 80), \amp, rrand(0.1, 0.3)]);
	})
})
);

r.play

//Ejemplo 2. .yield hace que la rutina se pause luego de cada iteración, es el usuario quien debe hacer que se vaya sucediento evaluando r.next
(
r = Routine.new({
	5.do({
		Synth(\saw, [\note, rrand(50, 80), \amp, rrand(0.1, 0.3)]).yield;
	})
})
);

r.next



//Ejemplo 3, en este caso .wait realizará un tiempo de espera medido en segundos. Al evaluar la rutina r.play se pondrá en marcha y realizará cada iteración con un segundo de espera entre sí
(
r = Routine.new({
	5.do({
		Synth(\saw, [\note, rrand(50, 80), \amp, rrand(0.1, 0.3)]);
		1.wait
	})
})
)

r.next //.next no respeta los tiempos de espera, realiza una iteración de la función y luego espera a la siguiente activación de r.next
r.play //.play pone en marcha la rutina respetando los tiempos de espera


//Ejemplo 2, inf significa infinito. Permite que una rutina se repita infinitamente
(
r = Routine.new({
	inf.do({
		Synth(\saw, [\note, rrand(50, 80), \amp, rrand(0.1, 0.3)]);
		1.wait
	})
})
)

r.play
r.stop

//Ejemplo 3, eligiendo las notas desde un array, y con valores de duración también elegidos desde un array
(
r = Routine.new({
	inf.do({
		Synth(\ping, [\note, [60, 62, 64, 67, 69].choose, \amp, exprand(0.01, 0.2)]);
		([0.1, 0.2, 0.4].choose).wait
	})
})
)

r.play
r.stop

//Creemos una segunda rutina para superponer a la primera
(
q = Routine.new({
	inf.do({
		Synth(\ping, [\note, [36, 38, 40, 43, 45].choose, \amp, exprand(0.1, 0.3)]);
		([1, 2, 4].choose).wait
	})
})
);


//Si evaluamos las dos rutinas juntas ya tenemos nuestro primer módulo de música generativa!
(
r.play;
q.play
)


	