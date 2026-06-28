//Sesión 1 Taller SuperCollider


s.boot;
s.makeWindow;
s.scope
FreqScope.new


//La doble barra permite escribir texto sin que formme parte del código

/* Para escribir un texto que ocupe varias líneas sin que sea código se puede utilizar la barra y el asterisco para abrir
y luego cerrar con asterisco barra, todo lo que se encuentre entre ellas será interpretado como anotaciones y no código */


/*Cuestiones básicas de sintaxis en SuperCollider
Las porciones de código suelen estar englobadas por paréntesis (), y a cada paréntesis abierto le corresponde uno de cierre. Los paréntesis tienen más funciones, por ejemplo contienen los argumentos de las UGENS unidades generadoras.
Las FUNCIONES se agrupan en llave {}, en ellas incluirémos porciones de código que envíen instrucciones al servidor para producir sonido o realizar operaciones.
Los ARRAYS, es decir colecciones de elementos, se agrupan con corechetes [].
Cuando necesitamos indicarle a SuperCollider que vamos a pasar a otra sección del código utilizamos punto y coma ;, sirven como separador de las distintas porciones del código
*/

//Ejemplo de una función sencilla
{LFTri.ar(110, 0, 0.1, 0)}.play;


//Ejemplo de una función con un Array
(
{
	SinOsc.ar( [220, 440], 0, 0.1, 0)
}.play
);


//Ejemplo de un Array
[100, 200, 300, 400, 500];


/*SuperCollider colorea los elementos del código que vamos escribiendo de manera distinta según reconoce a los elementos.
Las clases de objetos, entre los cuales se encuentran las UGENS, comienzan siempre por mayúscula. Los mensajes y métodos comienzan siempre por minúscula y van siempre precedidos de un punto.
Cuando evaluamos SinOsc.ar le estamos indicando al servidor que cree una instancia  de la UGEN SinOsc a frecuencia de audio (audio rate) de ahí el método .ar
Cuando a una función le indicamos el método .play, le estamos indicando al servidor que evalúe esa función y "la ponga en funcionamiento" como podemos ver en los ejemplos más arriba
*/



/*SuperCollider utiliza variables para contener información. El contenido de las variables es indicado por el usuario.
Existe variables globales o de entorno, y variables locales. Las variables de entorno van a ser reconocidas en cualquier parte del código que estemos trabajando. Las variables locales se utilizan en porciones de código pero serán solo válidas dentro de los paréntesis que las declaremos. Las variables en cualquier caso necesitan ser declaradas.
Las letras minúsculas funcionan como variables de entorno. Por default la letra s ya contiene el servidor de SuperCollider, por lo que no se recomienda declarar otra información ahí. Las variables globales también pueden ser declaradas como palabras siempre que comiencen con virgulilla ~
Las variables siempre deben comenzar por letras minúsculas
Las variables globales o de entorno son muy útiles cuando hay información a la que queremos acceder en varias partes del código, las locales suelen utilizarse para información que es necesaria solo en una parte del código
*/


//Ejemplo de variables locales en una operación sencilla
(
var num1, num2;
num1 = 1;
num2 = 7;
num1 + num2
)


//Ejemplo de variables locales en una función. Las variables pueden contener también UGENS o cualquier información que sea necesaria
(
{
	var sig, modu;
	modu = LFDNoise1.ar(5);
	sig = SinOsc.ar(550, 0, 0.1);
	sig = sig * modu;

}.play
)


//Variables globales
x = 5;
x.value;
x;


~variable1 = 123;
~variable1;
~variable1 = ~variable1 + x;
~variable1; //ahora nuestra variable quedó almacenada con el resultado que de la operación que hemos realizado


//Utilizar variables para almacenar funciones
(
y = {
	arg freq=440, amp=0.01;
	var sig;
	sig = Saw.ar(freq) * amp;
}.play;
)

//A continuación podemos cambiar los argumentos con el mensaje .set
y.set(\amp, 0.05);
y.set(\freq, 110);
y.set(\amp, 0.02, \freq, 220);
y.free;




//Tour of UGENS

SinOsc.ar //Onda Senoidal
LFTri.ar //Onda Triangular
LFPulse.ar //Onda Cuadrada
LFSaw.ar //Onda Diente de Sierra

{WhiteNoise.ar(0.1)}.play
{PinkNoise.ar(0.1)}.play
{BrownNoise.ar(0.1)}.play


{LFDNoise0.ar(800, 0.1)}.play
{LFDNoise1.ar(800, 0.1)}.play;
{LFDNoise3.ar(800, 0.1)}.play
{LFDClipNoise.ar(800, 0.1)}.play

//Podemos utilizar las UGens para modular otras señales
{LFDNoise0.ar(10).range(400, 420)}.plot(1)

(
{
var sig, mod1, mod2;
mod1 = LFDNoise0.ar(1).range(300, 320);
mod2 = LFDNoise1.ar(0.3).range(0.2,0.5);
sig = SinOsc.ar(mod1, 0, mod2);
sig = GVerb.ar(sig);
}.play
)




/* ARRAYS: Colección ordenada de elementos, se indican entre corchetes [] */

x = [100, 200, 1, 198, 800, -9];

x.size; //.size nos permite saber el tamaño del Array

//podemos acceder a un elemento específico del Array a través del método .at o simplemente indicando el índice. El primer índice del array es el 0
x.at(2);
x[2];

//de la misma manera podemos pedirle al Array que nos devuelva varios valores del array a la vez
x.at([0,2]);
x[[0,1,5]];



x = (0..100); //All the numbers from 0 to 100

//Se puede utilizar la clase Array para crear arrays

//series crea un Array con una progresión aritmética. Los argumentos indican el tamaño, el punto de comienzo y salto de item a item.
x = Array.series(101, 0, 2);

//.geom es una serie geométrica, en vez de sumar multiplica los items por el valor dado.
x = Array.geom(10, 2, 0.5);

//.rand genera un Array con elementos de valores aleatorios
x = Array.rand(10, 100, 200);


x = [100, 200, 300];
x + 5; //Se aplica a todos los elementos del Array
x * 5;
x / 5;


x = [100, 200, 300];
y = [1, 2, 3];
x + y;

//El array de menor cantidad de elementos se sigue repitiendo hasta completar los elementos del array más grande
x = [100, 200, 300, 400, 500, 600, 700, 800, 900];
y = [1, 2, 3];
x + y;


//El signo ! o el método .dup nos permiten crear un Array con copias del elemento que estamos duplicando
SinOsc.ar.dup(3);
-5.dup(7);
SinOsc.ar!3;
-5!7;


//Cuidado con estas diferencias
rrand(0, 5)!10;
rrand(0,5!10)

{BrownNoise.ar(0.1)!2}.play;
{BrownNoise.ar(0.1!2)}.play;






/*Amplitud modulada (AM)*/

//Función simple de amplitud modulada AM
{ SinOsc.ar(110, 0, SinOsc.ar(220)) }.play;
{ SinOsc.ar(110, 0, LFTri.ar(70)) }.play;


//Veamos una porción de código en la que dos señales se modulan entre sí (AM)
(
z = {
	arg amp=0.01, freq1=220, freq2=440;
	var sig1, sig2, out;
	sig1 = SinOsc.ar(freq1);
	sig2 = SinOsc.ar(freq2);
	out = sig1 * sig2 * amp;
	}.play
);

z.set(\amp, 0.1);
z.set(\freq1, 80);
z.set(\freq1, 110);
z.set(\freq1, 55);
z.set(\freq1, 0.3);


//Versión interactiva con el cursor
(
z = {
	arg amp=0.01;
	var sig1, sig2, out;
	sig1 = SinOsc.ar(440);
	sig2 = SinOsc.ar(MouseX.kr(1, 1500).poll);
	out = sig1 * sig2 * amp;
	}.play
);

z.set(\amp, 0.1);


//Complejicemos el ejemplo anterior
(
z = {
	arg amp=0.01;
	var sig1, sig2, out;
	sig1 = SinOsc.ar(MouseY.kr(50, 1500));
	sig2 = SinOsc.ar(MouseX.kr(50, 1500));
	out = sig1 * sig2 * amp;
	}.play
);

z.set(\amp, 0.1);
z.release(5)




/*Síntesis Substractiva*/
{BPF.ar(WhiteNoise.ar, 440, 0.01, 40)}.play;
{BRF.ar(WhiteNoise.ar, 440, 1, 1)}.play;
{LPF.ar(WhiteNoise.ar, 440)}.play
{HPF.ar(WhiteNoise.ar, 8000)}.play;


//Podemos elegir un generador de ruido para nuestra fuente sonora
{PinkNoise.ar(0.1)}.play;

//Filtramos el ruido rosa en este caso con un filtro pasa banda
{BPF.ar(PinkNoise.ar, 220, 1, 1)}.play;
{BPF.ar(PinkNoise.ar, 220, 0.01, 100)}.play;
{BPF.ar(PinkNoise.ar, 220, 0.0001, 1000)}.play;



//Complejicemos el ejemplo
(
{
	var sig, band, splay;

	sig = PinkNoise.ar;

	band = BPF.ar( sig,
		[80, 485, 872, 1000, 1070, 2080],
		0.01,
		10);

	splay = Splay.ar(band);

}.play
)


//Agreguemos parámetros de modulación y utilicemos el método .range

(
{
	var sig, band, splay, modu;

	sig = PinkNoise.ar;

	modu = LFDNoise3.ar([0.1, 0.2, 0.05, 0.1]);

	band = BPF.ar(
		sig,
		[80, 485, 682, 872, 1000, 1070, 2080] * modu.range(1, 1.1),
		0.01,
		[100, 50, 30, 30, 20, 15, 5] * modu);

	splay = Splay.ar(band, 0.3);

}.play
);





/*Ubicar señales monocanal y multicanal en el campo stereo*/

//Pan2 es una UGen que permite panoramizar señales mono en dos canales
(
x = {
	arg amp=0.1;
	var sig, modu, pan;

	modu = LFDNoise0.kr(3).range(100, 1000).round(100);

	sig = SinOsc.ar(modu, 0, amp);

	pan = Pan2.ar( sig, SinOsc.kr(0.1));
}.play
)

//Mix nos permite convertir una señal multicanal en mono
(
x = {
	arg amp=0.1;
	var sig, frecs, pan;

	frecs = Array.geom(8, 50, 1.5);

	sig = Mix(SinOsc.ar(frecs, 0, amp));

	pan = Pan2.ar( sig, SinOsc.kr(0.1));
}.play
)

//Splay distribuye en el campo stereo señales multicanales. Uno de sus argumentos es un valor que indica que tan separados estarán esos elementos. 0 es mono, 1 y -1 lo más separados posibles.
(
x = {
	arg amp=0.1;
	var sig, frecs, pan;

	frecs = Array.geom(8, 50, 1.5);

	sig = SinOsc.ar(frecs, 0, amp);

	pan = Splay.ar( sig, SinOsc.kr(0.1));
}.play
)




//SynthDef y Synth
//
(
SynthDef(\panda,
	{
		arg note, amp;
		var sig, env;
		sig = LFTri.ar(note!2);
		env = EnvGen.ar(
			Env.perc,
			doneAction:2);
		sig = sig * env;
		Out.ar(0, sig * amp);
}).add
);

Synth(\panda, [\note, rrand(40, 50).midicps, \amp, 0.1]);
















