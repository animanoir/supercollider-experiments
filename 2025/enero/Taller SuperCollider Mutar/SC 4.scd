/*
Super Collider Clase 4

En este clase veremos

Asignación de variables

Entradas de audio y SoundIn

Rutinas y Patrones

*/

s.boot;
s.makeWindow;



//SuperCollider tiene la posibilidad de asignar variables de la siguiente manera. Luego vamos a ver cómo utilizar este recurso con nuestras UGens. En el siguiente ejemplo vemos cómo se le asigna a cada una de las variables seleccionadas un elemento del array, de forma consecutiva.
# a, b, c = [100, 200, 300];
a.value;
b.value;
c.value;

//Otro ejemplo de asignación de variables
#a, e, z = [rrand(100,200), 27, 400];
a.value;
e.value;
z.value;



/*
Entradas de audio, SoundIn


La manera de utilizar una entrada de audio es a través de la UGen SoundIn. Esta UGen nos permite utilizar la señal del de la entrada de audio y podemos tratarla como la señal de una UGen Cualquiera
*/


//En SuperCollider podemos asignar las interfaces de entrada, además de los buses de entrada y salida

//En Windows y Mac estas líneas de código debieran darnos un listado de los dispositivos e interfaces que están disponibles
ServerOptions.devices; // todos los dispositivos
ServerOptions.inDevices; // dispositivos de entrada
ServerOptions.outDevices; // dispositivos de salida


//En Mac para conectar un dispositivo
Server.default.options.device_("MOTU 828"); // entre comillas "" el nombre del dispositivo a conectar

//Los siguientes códigos es en caso que queramos conectar solo dispositivos de entrada o salida
Server.default.options.inDevice_("Built-in Microph");
Server.default.options.outDevice_("Built-in Output");

//En Windows los archivos de ayuda nos indican que podemos conectar un dispositivo de audio de la siguiente manera
o = Server.default.options;
o.inDevice_("Windows WASAPI : Microphone"); //indicar el dispositivo de entrada
o.outDevice_("Windows WASAPI : Speakers"); // dispositivo de salida
Server.default.reboot; //reiniciar el servidor


//En caso que necesitemos indicar el número de salidas o entradas
s.options.numOutputBusChannels = 8 //Si necesitamos canales de audio
s.options.numInputBusChannels = 8 //Si vamos a necesitar 8 entradas



//SoundIn necesita como primer argumento el bus de entrada, es decir el canal de entrada/micrófono, y luego mul y add como el resto de UGens

(
x = {
	arg modfrec=1, amp=0.5;
	var sig, modu;

	modu = SinOsc.ar(modfrec);

	sig = SoundIn.ar(0, amp)!2; //Canal de entrada 0, amp será el argumento que controle la amplitud, !2 que copie la señal en los canales 0 y 1 de salida

	sig = sig * modu
}.play
)

x.set(\amp, 1);
x.set(\modfrec, 5); //trémolo
x.set(\modfrec, 500) //AM, modulación de amplitud
x.release(5);


//Variación del ejemplo anterior con la UGen Pitch. Esta UGen detecta la frecuencia de una señal, y nos da como resultado el número de frecuencia y un valor true/false si cree que la detección ha sigo correcta o no. Aquí podemos utilizar la asignación de variables para los valores que da como resultado Pitch
(
u = {
	arg amp=0.01;

	var sig, sine, freq, hasFreq;

	sig = SoundIn.ar(0)!2;

	# freq, hasFreq = Pitch.kr(sig, ampThreshold:0.05);

	sine = SinOsc.ar(freq)!2;

	sig = sig + sine;

	sig * amp
}.play
)

u.set(\amp, 0.75);
u.release(5);


//Otro ejemplo con SoundIn. Aquí tendremos la señal limpia en el canal izquierdo, y la señal procesada en el canal derecho. Pasaremos nuestra señal por un filtro comb cuyo tiempo de retardo será variable, modulada por un SinOsc
(
y = {
	arg modfrec=0.1, tempmin=0.1, tempmax=5, amp=0.5;

	var input, comb;

	input = SoundIn.ar(0, amp)!2;

	comb = CombC.ar(input, 10, SinOsc.kr(modfrec).range(tempmin, tempmax));

	[input, comb]
}.play
)

y.set(\amp, 1);
y.set(\modfrec, 0.05);
y.set(\tempmax, 3);
y.release(5);


//Otro ejemplo con SoundIn y filtros Allpass. Reverb simple. El filtro Allpass deja pasar todas las frecuencias, aunque realiza cambios de fase, y también nos permite indicar tiempos de retardo, por lo que podemos emular las reflexiones de una reverb

AllpassN.ar( in, maxdelaytime, delaytime, decaytime, mul, add);

(
q = {
	arg time=2;
	var input, signal;

	input = SoundIn.ar(0, 0.3)!2;

	//con 20.do creamos 20 instancias distintas de la señal filtrada por los filtros Allpass, cada uno con un tiempo de retardo diferente
	20.do({ input = AllpassN.ar(input, 0.05, { rrand(0.005, 0.05)} !2, time) });

	input

}.play
);

q.set(\time, 1.15);
q.set(\time, 0.25); //slapback echo
q.set(\time, 3);
q.realease(5);




/*
Sobre Rutinas y .play
*/

/*
Una rutina es una función en la que sus acciones y sus procesos pueden ser secuenciados. Por ende es sincronizada con el tempo de un reloj. Por eso es que cada vez que la rutina recibe el mensaje .wait hay que asignarle un número. Ese número está siempre en relación de la manera que el reloj de SuperCollider mide el tiempo. Actúa básicamente como un metrónomo. El reloj por defecto de las rutinas interpreta la duración como pulsos y su tempo por defecto es 60 MM (velocidad de metrónomo).

Si queremos cambiar el tempo tenemos TempoClock*/

TempoClock.new(tempo)

/*tempo - el tempo del reloj expresado en pulsos por segundo

1 - si queremos un tempo de 60 MM (60/60)
2 - si queremos un tempo de 120 MM (120/60)
0.5 - si queremos un tempo de 30 MM (30/60)
2.16 - si queremos un tempo de 130 MM (130/60)
0.66 - si queremos un tempo de 40 MM (40/60)
*/

//También podemos comunicarlos con el metrónomo/reloj de nuestra rutina e indicarle otro tempo con el mensaje .clock y el mensaje .tempo
r.clock.tempo
r.clock.tempo = 60/60




/*
Patrones y Streams
*/


//Pseq lo que hace es reproducir valores de una lista cíclicamente. Primero necesita la lista (en forma de Array) y luego la cantidad de repeticiones. El mensaje asStream nos permite reproducirlo con una Stream de datos, es decir como una rutina e incluir los patrones en ellas.
a = Pseq([1, 2, 3], 2).asStream
a.next


//En el siguiente ejemplo veremos cómo Pseq repetirá 4 veces los valores del array, y una vez que termine no dará valores, simplemente responderá nil
b = Pseq([10, 100, 1000, 100], 5).asStream;
b.next

//Si queremos que un patrón funcione infinitamente lo podemos indicar con inf
c = Pseq([3, 5, 7, 11], inf).asStream;
c.next


//Retomemos el primer ejemplo que hemos visto con SoundIn, amplitud modulada. En este ejemplo de rutina vamos a ver cómo utilizar un patrón para repetir cíclicamente las frecuencias de modulación.
(
x = {
	arg modfrec=1, amp=0.5;
	var sig, modu;

	modu = SinOsc.ar(modfrec);

	sig = SoundIn.ar(0, amp)!2; //Canal de entrada 0, amp será el argumento que controle la amplitud, !2 que copie la señal en los canales 0 y 1 de salida

	sig = sig * modu
}.play
);


(
r = Routine({
	var frecs;

	frecs = Pseq([100, 200, 300, 400, 500], inf).asStream;

	inf.do({
		x.set(\modfrec, frecs.next);
		0.25.wait
	})
}).play
);

r.stop
x.release(1);


//Probemos ahora con un sintetizador sencillo
(
SynthDef(\ping, {
	arg note=60, amp=0.1;
	var sig, env;

	env = EnvGen.kr( Env.perc, doneAction:2);

	sig = LFTri.ar(note, 0, amp)!2;

	Out.ar(0, sig * env);
}).add

)

Synth(\ping);




//En la siguiente rutina vemos cómo podemos usar Pseq para que se repita una serie de notas de manera cíclica (la escala de do menor)

(
q = Routine({
	var frecs, amps, durs;

	frecs = Pseq([60, 62, 63, 65, 67, 68, 70, 72], inf).asStream;

	inf.do({
		Synth(\ping, [
			\note, frecs.next.midicps,
			\amp, 0.2
		]);
		0.5.wait
	})
})
);

q.play
q.stop


//Pseq se puede aplicar a las amplitudes, duraciones o frecuencias. Aquí vemos como la secuencia de notas se repite, con el mismo patrón rítmico y siempre acentuada la primera nota
(
r = Routine({
	var frecs, amps, durs;

	frecs = Pseq([60, 63, 60, 70], inf).asStream;

	amps = Pseq([0.5, 0.1, 0.1, 0.1], inf).asStream;

	durs = Pseq([0.75, 0.25, 0.5, 0.5], inf).asStream;

	inf.do({
		Synth(\ping, [
			\note, frecs.next.midicps,
			\amp, amps.next
		]);
		durs.next.wait
	})
})
);

r.play;
r.stop;


//Podemos incluir Pseqs dentro de Pseqs. En el caso siguiente lo vamos a implementar en las frecuencias. Cada Pseq se repetirá dos veces y luego dará paso al siguiente Pseq.
(
w = Routine({
	var frecs, amps, durs;

	frecs = Pseq([Pseq([60, 62, 60, 63],2), Pseq([70, 72, 70, 69], 2)], inf).asStream;

	amps = Pseq([0.5, 0.1, 0.1, 0.1], inf).asStream;

	inf.do({
		Synth(\ping, [
			\note, frecs.next.midicps,
			\amp, amps.next
		]);
		(1/6).wait
	})
})
);

w.play;
w.stop;


//Existen otro tipo de Patrones además de Pseq, veamos algunos ejemplos

//Pwhite da valores random, se parece mucho a un generador de números aleatorios
a = Pwhite(0, 10, inf).asStream;
a.next;

//Prand elige valores random de una lista
b = Prand([5, 10, 15, 20], inf).asStream;
b.next

//Pxrand nunca elige también valores random de una lista, pero nunca elige dos veces el mismo valor
c = Pxrand([5, 10, 15, 20], inf).asStream;
c.next;

//Pwrand elige elementos dentro de una lista pero podemos elegir las probabilidades que tiene un elemento de salir a través de un array que indique los "pesos"
d = Pwrand([5, 10, 15, 20], [0.7, 0.1, 0.1, 0.1], inf).asStream;
d.next;

//Pshuf desordena los elementos dentro de una lista, funciona un poco como el método .scramble. Los desordena solo una vez y luego lo guarda así
e = Pshuf([5, 10, 15, 20], inf).asStream
e.next

//Pn nos permite implementar algunos procesos como Pshuf, se encarga de reproducir un proceso una cantidad n de veces. Es ideal para funcionar con Pshuf y otros patrones para que cambien sus permutaciones
f = Pn(Pshuf([1, 2, 3], 2), inf).asStream;
f.next


//Veamos un ejemplo de Pn y Pshuf dentro de una rutina para controla el parámetro de alturas de nuestro sintetizador
(
r = Routine({
	var frecs, amps, durs;

	frecs = Pn(Pshuf([48, 60, 62, 63], 2), inf).asStream;

	inf.do({
		Synth(\ping, [
			\note, frecs.next.midicps,
			\amp, 0.2
		]);
		0.5.wait
	})
})
);

r.play
r.stop


//Otro ejemplo con Pn y Pshuf. Podemos poner patrones dentro de patrones.
(
r = Routine({
	var frecs, amps, durs;

	frecs = Pn(Pshuf([48, 49, 50, Pseq([72, 70, 69], 1)], 2), inf).asStream;

	inf.do({
		Synth(\ping, [
			\note, frecs.next.midicps,
			\amp, 0.2
		]);
		0.3.wait
	})
})
);

r.play
r.stop



//Existe una manera de implementar los patrones sin incluir el mensaje de .asStream, a través de Pbind. Pbind lo que hace es asignar los patrones al parámetro que queramos controlar a través del nombre de su argumento.
//Veamos los argumentos que admite nuestro sintetizador
(
SynthDef(\ping, {
	arg note=60, amp=0.1;
	var sig, env;

	env = EnvGen.kr( Env.perc, doneAction:2);

	sig = LFTri.ar(note, 0, amp)!2;

	Out.ar(0, sig * env);
}).add

)


(
p = Pbind(
	\instrument, \ping,
	\note, Pseq([60, 62, 63, 70], inf).midicps,
	\amp, Pn(Pshuf([0.5, 0.1, 0.1], 2), inf),
	\dur, 0.5
).play
);

p.pause; //Pbind puede pausarse y luego continuar
p.play;
p.stop;


(
p = Pbind(
	\instrument, \ping,
	\note, Pseq([48, 60, 72, 70], inf).midicps,
	\amp, Pwrand([0.1, 0.5], [0.9, 0.1], inf),
	\dur, Pseq([1, 0.5, 0.25, 0.25], inf)
).play
);


//Pbind funciona por asociación de símbolos y argumentos. Le podemos asignar a cada símbolo un patrón o un valor. También necesita un valor para las duraciones, de ahí que tengamos que indicar el valor (o serie de valores) para \dur, es decir la duración.

//Si necesitamos sincronicar diferentes Pbinds podemos utilizar Ppar. Esto nos permite asegurarnos que los patrones van a comenzar sincronizados y crear polirritmias y polimetrías.

//Los números fraccionarios nos permiten representar relaciones temporales. Si recordamos lo visto anteriormente sobre el reloj en SuperCollider podemos interpretar en la siguiente función que uno de los Pbinds hará 3 notas cada 4 segundos, y el siguiente hará 7 en el mismo tiempo.
(
h = Ppar(
	[
		Pbind(\note, 60.midicps, \dur, 4/3, \instrument, \ping),
		Pbind(\note, 36.midicps, \dur, 4/7, \instrument, \ping)
	]
).play
);

h.pause
h.play
h.stop


//Patron polirítmico, 7 notas contra 5. En la melodía superior hará la escala de do mayor, en el bajo hará la pentatónica de do mayor.
(
i = Ppar(
	[
		Pbind(\note, Pseq([60, 62, 64, 65, 67, 69, 71], inf).midicps, \dur, 4/7, \instrument, \ping),
		Pbind(\note, Pseq([36, 38, 40, 43, 45], inf).midicps, \dur, 4/5, \instrument, \ping)
	]
).play
);

i.pause
i.play
i.stop


//Rest es una clase que nos permite incluir silencios en nuestros patrones y series de notas. Si bien podríamos asignar un valor de amplitud 0 en caso que quisiéramos hacer que una nota no suene, Rest es otra opción con la que incluir silencios.
(
j = Pbind(
	\instrument, \ping,
	\note, Pseq([60, Rest(1), 62, Rest(1),67, 69, 67, Rest(1)], inf).midicps,
	\amp, Pseq([0.125, 0.25, 0.5, 0.75], inf),
	\dur, 0.5
).play
);

j.pause
j.play
j.stop

//Ahora con duraciones elegidas aleatoriamente. Pxrand elegirá valores que son 1 seg, 0.5 seg, 0.25 seg, 0.125 seg. Pensemos que estamos en un tempo de 60 bpm, podemos pensar que 1 es = 1 negra, 0.5 = 1/2 = 1 corchea, 0.25 = 1/4 = 1 semicorchea, 0.125 = 1/8 = 1 fusa
(
j = Pbind(
	\instrument, \ping,
	\note, Pseq([60, Rest(1), 62, Rest(1),67, 69, 67, Rest(1)], inf).midicps,
	\amp, Pseq([0.125, 0.25, 0.5, 0.75], inf),
	\dur, Pxrand([1, 0.5, 0.25, 0.125], inf)
).play
);

k.pause
k.play
k.stop


//Los patrones y Pbind son formas fáciles y simples de implementar patrones para las duraciones de nuestros sintetizadores. Es una forma complementaria del trabajo con rutinas, que si bien requieren más programación pueden resultar más flexibles y "artesanales" a la hora de especificar qué deseamos que haga SuperCollider por nosotros.

