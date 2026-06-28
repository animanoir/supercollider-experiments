/*
Reproducción de archivos de audio

Buffers

BufRd y PlayBuf
*/


/*
Podemos leer archivos de audio directamente desde el disco duro de nuestro ordenador con la clase SoundFile.

Para mayor flexibilidad y manipular nuestros archivos de diferentes maneras podemos cargar nuestros archivos en un Buffer y luego reproducirlo con las UGens correspondientes.

Un buffer es una porción de memoria reservada con una función, en este caso para cargar un archivo de audio.

SuperCollider lee archivos .wav o .aiff pero no mp3 u otros formatos.

SuperCollider solo lee archivos que tengan carácteres del alfabeto inglés, por lo tanto no acepta nombres de archivos ni rutas (es decir que su directorio tenga un nombre con) ñ, ó, á, é, ç, etc.

La manera más fácil de saber la ruta de un archivo de audio en SuperCollider es arrastrar el archivo a la pantalla de SuperCollider y nos aparecerá la ruta completa (directorio y nombre de archivo

Podemos asignar un buffer y una variable a ese archivo y ruta de audio para luego leerlo con alguna de las UGens que se dedican a reproducir archivos de audio
*/



//SoundFile para reproducir un archivo directamente desde nuestro disco duro. El nombre de archivo y la ruta debe estar entre comillas ""
SoundFile.new( "ruta de nuestro archivo de audio" ).play;

//El siguiente ejemplo funcionará en todos los ordenadores. SuperCollider tiene un archivo de audio por default que viene con la instalación y se encuentra entre los archivos y carpetas donde se encuentre alojado en nuestro disco duro. Platform.resourceDir nos permite acceder directamente a ese directorio y luego a ese archivo de audio
f = SoundFile.new(Platform.resourceDir +/+ "sounds/a11wlk01.wav");
f.play;




/*
Buffers

La clase Buffer nos permite cargar un archivo en la memoria para luego manipularlo. Los argumentos de Buffer.read son los siguientes:

Buffer.read(server, path, startFrame, numFrames, action, bufnum)

- en "server" vamos a colocar el servidor local, es suficiente con indicar la variable s.
- "path" es la ruta de nuestro archivo de audio
- "startFrame" es el frame por el que comenzará a reproducir el archivo
- "numFrames" es la cantidad de frames que tiene un archivo de audio
- "action" es una acción que realiza Buffer una vez haya terminado de cargar el archivo de audio.
- "bufnum" es el número de buffer en el servidor
*/

Buffer.read(server, path, startFrame, numFrames, action, bufnum)


//Vamos a cargar en un buffer un archivo de audio. En esta ocasión usaremos ell archivo por default allwlk01.wav
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


/*
PlayBuf


PlayBuf tiene como argumentos:

-"numChannels" el número de canales. Debe coincidir con el número de canales que tenga nuestro archivo de audio, si es mono 1, si es stereo 2.

-"bufnum" el número de buffer en el servidor

-"rate" se podría interpretar como la velocidad a la que es reproducido el archivo de audio. 1 es a la velocidad a la que está, 2 es al doble, 0.5 a la mitad, 0.25 a un cuarto de velocidad. Tener cuidado que nuestro archivo de audio esté al mismo sample rate que el servidor de SuperCollider (lo podríamos corregir con BufRateScale, una UGen que adapta nuestra frecuencia de muestreo


-trigger, funciona como un argumento de gate. Al recibir un 1 reproducirá nuestro archivo de audio.

-startPos, es decir a partir de qué frame empieza a reproducir nuestro archivo de audio.

-"loop" hace que se reproduzca nuestro archivo en bucle o no. 1 para que reproduzca en bucle (e ignorará el argumento de doneAction), 0 para que no lo reproduzca en bucle.

-doneAction funciona de la misma manera que en EnvGen, 0 no hace nada, 2 destruye el synth en el servidor
*/

PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop, doneAction);


//Podemos integrar PlayBuf desde un SynthDef para reproducirlo luego;

(
SynthDef(\player, {
	arg amp=1, buf, rate=1, t_trig=1, start=0, loop=0, doneaction=2;
	var sig;

	sig = PlayBuf.ar(1, buf, rate, t_trig, start, loop, doneaction);
	Out.ar(0, sig * amp)

}).add
);

//.bufnum obtiene el número de buffer del buffer alojado en la variable b
Synth(\player, [\buf, b.bufnum]);
b.bufnum;


//Otros ejemplos
//Reproducir un archivo en bucle
x = Synth(\player, [\buf, b.bufnum, \loop, 1]);
x.set(\loop, 0) //para que deje de reproducir en bucle

//Reproducir un archivo al doble de velocidad
Synth(\player, [\buf, b.bufnum, \rate, 1]);

//Reproducir un archivo a la mitad de su velocidad
Synth(\player, [\buf, b.bufnum, \rate, 0.5]);

//Para activarlo a través de un trigger, reproducirá desde la posición de comienzo startPos (recuerden cambiar doneAction a 0)
x = Synth(\player, [\buf, b.bufnum, \doneaction, 0, \rate, 0.75]);
x.set(\t_trig, 1)


/*Es divertido implementar lectura de Buffer con rutinas

En el siguiente ejemplo se reproducirá cada vez el archivo de audio a una velocidad distinta.

Para que el tiempo de espera coincida con la duración del archivo podemos colocar el número de frames (b.numFrames) dividido por la sample rate del servidor de SuperCollider (en mi caso 44100), a su vez dividido por el rate que esté reproduciendo en el momento.

la rate (velocidad de reproducción) cambia cada vez porque la variable que define el rate está dentro de inf.do, por lo que cada vez que es evaluada esa función, es evaluada la línea que "rate = rrand(0.25, 4)". Tendremos valores aleatorios que van desde un cuarto de velocidad hasta cuatro veces la velocidad original.
*/
(
r = Routine({
	var rate;
	inf.do({
		rate = rrand(0.25, 4);


		Synth(\player, [\buf, b.bufnum, \doneaction, 0, \rate, rate]);

		((b.numFrames / 48000)/rate).wait;
	})
}).play
);

r.stop;


/*
BufRd

Sus argumentos son:

-"numChannels" número de canales igual que en PlayBuf, debe coincidir con los del archivo de audio a reproducir.

-"bufnum" número de buffer que vamos a reproducir.

-"phase" este argumento permite leer la posición de nuestro buffer a través de una UGen en audio rate (.ar). Esa Ugen actuará como un "pointer" o puntero que indica qué frame de nuestro archivo de audio debe ser reproducido

-"loop" igual que ne PlayBuf

*/

BufRd.ar(numChannels, bufnum, phase, loop, interpolation);


//Creemos distintos SynthDefs con diferentes UGen que lean nuestro buffer con BuferRd

//Para que lo lea linealmente, utilizaremos la UGen Line.ar como pointer
(
SynthDef(\playerrd1, {
	arg buf, start, end;
	var sig, pointer;

	//BufDur.kr nos permite obetener la duración de nuestro buffer
	pointer = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(1, buf, pointer);
	Out.ar(0, sig);
}).add
);

//Reproducir un archivo de principio a fin
Synth(\playerrd1, [\buf, b.bufnum, \start, 0, \end, b.numFrames]);

//Reproducir un archivo desde el final al comienzo
Synth(\playerrd1, [\buf, b.bufnum, \start, b.numFrames, \end, 0]);


//Podemos utilizar otro tipo de UGens como pointers
(
SynthDef(\playerrd2, {
	arg buf, start, end, rate;
	var sig, pointer;

	//Utilizaremos un SinOsc. El argumento rate definirá a qué velocidad realiza el ciclo
	pointer = SinOsc.ar(rate).range(start, end);

	sig = BufRd.ar(1, buf, pointer);

	Out.ar(0, sig);
}).add
);

//Veamos el resultado con distintos rates
x = Synth(\playerrd2, [\buf, b.bufnum, \start, 0, \end, b.numFrames, \rate, 1]);
x.free;

x = Synth(\playerrd2, [\buf, b.bufnum, \start, 0, \end, b.numFrames, \rate, 0.5]);
x.free;

x = Synth(\playerrd2, [\buf, b.bufnum, \start, 0, \end, b.numFrames, \rate, 0.1]);
x.free;

x = Synth(\playerrd2, [\buf, b.bufnum, \start, 0, \end, b.numFrames, \rate, 0.05]);
x.free

//Probemos una variante en que Phasor sea la UGen que actúa como pointer, el cuál genera rampas entre dos puntos en bucle.
(
SynthDef(\playerrd3, {
	arg buf, start, end, rate;
	var sig, pointer;

	pointer = Phasor.ar(0, rate, start, end);

	sig = BufRd.ar(1, buf, pointer);

	Out.ar(0, sig);
}).add
);

//Podemos ir cambiando el rate, su posición de comienzo y final mientras realiza el bucle
x = Synth(\playerrd3, [\buf, b.bufnum, \start, 0, \end, b.numFrames, \rate, 1]);

//Cada vez que evaluemos la siguiente línea de código el punto de comienzo, final, y el rate tendrán un valor aleatorio distinto
x.set(\start, rrand(0, b.numFrames), \end, rrand(0, b.numFrames), \rate, rrand(0.25, 4))