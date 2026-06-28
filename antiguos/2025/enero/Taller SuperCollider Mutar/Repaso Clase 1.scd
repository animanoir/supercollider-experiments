//Repaso y ejercicios de la Clase 1



/*
Las letras minúsculas son variables de entorno, no necesitan ser declaradas. La letra s tiene almacenado el servidor de SuperCollider.
Con los siguientes métodos podemos realizar operaciones sobre el servidor.
*/


s.boot; //iniciar el servidor
s.quit //detener el servidor

s.makeWindow; //.makeWindow nos permite acceder a los controles globales del servidor

s.scope; //.scope nos permite observar los buses del servidor (audio y control)

FreqScope.new; //FreqScope es una clase de objetos que nos permite abrir un analizador de frecuencias para observar el espectro de nuestras señales de audio




//Las variables pueden contener cualquier cosa que les asignemos, incluidas UGens

x = {SinOsc.ar(220)}; //x contiene un oscilador de ondas senoidales cuya frecuencia es 220Hz

x.play //.play "pone a andar" la función

x.plot(1/220) //.plot imprime una porción de tiempo indicado de la función contenida en x. En este caso una fracción de 1/220 segundos. Es decir un ciclo de la onda.




//Las UGens pueden utilizarse para modular otras señales y controlar parámetros.

{SinOsc.ar(200, 0, SinOsc.kr(1))!2}.play //El segundo SinOsc estámodulando la amplitud de la primera señal cuya frecuencia es 220Hz


{SinOsc.ar( SinOsc.kr(1).range(100,200))!2}.play //El segundo SinOsc está controlando la frencuencia, proporcionando valores en un rango de 100 a 200Hz


//Podemos controlar los valores de salida de una UGen utilizando el método .range, o indicando sus valores de mul y add
{SinOsc.ar( SinOsc.kr(1, 0, 50, 150))}.play //Esta función tiene el mismo resultado que el ejemplo anterior




/*Arrays
Son colecciones de elementos. Existen métodos que nos permiten crear arrays muy grandes muy rápidamente
*/

Array.series(100, 50, 50); //Array de 100 elementos, que comienzan en el valor 50 y van creciendo de 50 en 50 linealmente
Array.geom(100, 50, 1.1); //Array de 100 elementos, que comienza en el valor 50 y crece con una progresión geométrica
Array.rand(100, 50, 5000); //Array cde 100 elementos, con valores random entre 50 y 5000




//Las variables locales y los argumentos deben ser declarados al principio  de la porción de código que vayamos a evaluar

//El siguiente código nos permite indicar la frecuencia de una onda triangular y su amplitud.
(
y= {
	arg freq=100, amp=0.5;
	var sig;
	sig = LFTri.ar( freq, 0, amp)!2;
}.play
)

y.set(\amp, 0.5);
y.set(\freq, 70);
y.free //para liberar la variable
y.release(5) //realiza un fade out indicado en segundos


//El siguiente código es un poco más complejo. Tenemos un oscilador el cuál es modulado en frecuencia por un generador de ruido blanco, y en amplitud por un generador  de ruido LFDNoise0.
(
z ={
	arg minfreq=100, maxfreq=120, amp=0.1; //así podremos cambiar las frecuencias máximas y mínimas, y la amplitud del SinOsc

	var sig, modufreq, moduamp, pan; //Utilizaremos 3 variables

	pan = LFDNoise0.ar(7.5);

	modufreq = WhiteNoise.ar.range(minfreq, maxfreq); //Generador de ruido blanco, sus valores máximos y mínimos serán dados por los argumentos minfreq y maxfreq

	moduamp = LFDNoise0.ar(7.5); //generador de ruido que da 7.5 valores aleatorios por segundo

	sig = SinOsc.ar( modufreq, 0, amp); //modufreq en el lugar del argumento de frecuencia, y amp en el lugar del argumento mul
	sig = Pan2.ar(sig, moduamp);

	sig = sig * moduamp; //multiplicamos la señal de nuestro oscilador por el LFDNoise0 para que tenga un sonido más "glitch"
}.play
)

z.set(\amp, 0.5); //el método .set nos permite cambiar algún argumento de la variable
z.set(\maxfreq, 120);
z.set(\minfreq, 20);
z.set(\minfreq, 100);
z.release(3);

// modulate numharmonics
(
b = {
	var sig, pan;
	pan = LFDNoise3.ar(7.5);
	sig = Blip.ar(100,LFDNoise1.ar(7.5).range(1,100),0.2);
	sig = Pan2.ar(sig, pan);
}.play;
)

(
~sonido = {
	arg minFreq=200, maxFreq=1200, amp=0.5;

	var sig, modFreq, modAmp, pan;

	pan = LFDNoise0.ar(7.5);
	modFreq = WhiteNoise.ar.range(minFreq, maxFreq);
	modAmp = LFDNoise0(7.5);
	sig = Blip.ar(modFreq, 200.0, amp);
	sig = Pan2.ar(sig, modAmp);
	sig = sig*modAmp;
}.play;
)
~sonido.free;



//Ejemplo de síntesis substractiva. ClipNoise es filtrado por un un filtro pasabandas que contiene un array de 8 valores en el argumento de frecuencia. A continuación es convertido en una señal monocanal a través de Mix. En la última línea vemos como gracias a la UGen Pan2 logramos panoramizar la señal. SinOsc.kr se encuentra en el argumento de posición dando movimiento entre los dos canales.
(
{
	var sig;

	sig = ClipNoise.ar;

	sig = BPF.ar( sig, [70, 80, 120, 235, 310, 361, 396, 520], 0.01, 20);

	sig = Mix.new(sig);

	sig = Pan2.ar(sig, SinOsc.kr(1).range(-0.75, 0.75));

}.play
);






//Ejercicio 1, generar una porción de código que cuente con un oscilador (puede ser de ondas senoidales, triangulares, diente de sierra, cuadrada u algún oscilador de baja frecuencia). Su frecuencia y su amplitud deben ser moduladas por otras señales (también a libre elección el tipo de UGen).

s.boot;
s.quit;


(
{
	var sin1, sin2, pan, pan2;
	var sinV = 5.0;
	var intervals = [1,1.125,1.333,1.5,1.875];
	sin1 = SinOsc.ar(freq: LFDNoise0.kr(sinV).range(100,500));
	pan = Pan2.ar(sin1, LFDNoise1.kr(sinV));
}.play;
)



(
{
	var tri1, ampMod;
	ampMod = LFDNoise0.ar(5).range(0,1);
	tri1 = SinOsc.ar(freq: LFDNoise0.kr(0.5).range(100,500), mul: LFDNoise0.kr(0.5))!2;
	tri1 = tri1 * ampMod;
}.play;
)



//Ejercicio 2, síntesis substractiva. Generar una porción de código en la que un ruido (blanco, rosa, browniano, clipnoise) sea filtrado por un filtro pasabanda (BPF) con un Array de 12 frecuencias (colocar el array en el argumento de frecuencias). Todas las frecuencias deben escucharse en los canales de audio (utilizar cualquier técnica para distribuir la señal en los canales 0 y 1 de audio, Splay, Mix y Pan2, Mix y !2). Recuerden poner un valor de rq bajo paara que se distingan las frecuencias!








