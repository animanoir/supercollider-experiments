/*

Protocolo OSC

Envolventes con sustain

*/



/*En esta clase vamos a ver cómo utilizar SuperCollider con una aplicación externa a través de protocolo OSC
OSC son las siglas de Open Sound Control. Este protocolo nos permite contectar varios dispositivos que estén conectados a la misma red de internet.

Los ejemplos en esta clase serán dados con la aplicación OSC Controller para Android, pero cualquier dispositivo OSC funciona de manera similar.


Como primer paso debemos averiguar la dirección de IP que tiene el dispositivo desde el que estamos operando SuperCollider (nuestro ordenador).
Guardemos esta información.

Al abrir nuestra aplicación OSC Controller nos vamos a encontrar con uun panel de control en el que nos pide una dirección de IP, y un puerto.
En dirección de IP debemos colocar la misma dirección de IP que tiene la conexión de nuestro ordenador.
El número de puerto por default de SuperCollider es 57120

Con esos dos datos podemos ya conectar la aplicación*/


//En caso que necesitemos comprobar el puerto de SuperCollider podemos utilizar el siguiente código
NetAddr.langPort;


//Así como tenemos SynthDef para definir sintetizadores, el protocolo OSC en SuperCollider utiliza una clase llamada OSCdef, que nos permite indicarle al servidor qué hacer cuando ser reciben mensajes por OSC



//Ejemplo sencillo. Al igual que con SynthDef, OSCdef necesita que le demos un nombre con un símbolo.
(
OSCdef(\prueba,
	{
	arg msg, time, addr, port;
	[msg, time, addr, port].postln;
	},
	'/accelerometer/x'
)
);


//Una OSCdef incluye por definición los argumentos del mensaje, tiempo, dirección de red, y el puerto, en ese orden. En el ejemplo anterior declaramos los argumentos que nos dará nuestro OSCdef, y en la línea siguiente los indicamos en un Array que recibirá el mensaje .postln para que los imprima en el post window. Luego de de indicar la función debemos indicar desde qué toggle/botón/slider/etc queremos recibir esa información.

//El nombre de cada toggle/botón/slider/etc lo podemos encontrar en la aplicación al seleccionar la opción de editar


//Veamos un ejemplo aún más sencillo con el toggle2. Con el siguiente OSCdef queremos solo imprimir la información del primer argumento del mensaje OSC. Al ser un toggle tiene posición de encendido o apagado, da valores de 0 o 1.
(
OSCdef(\prueba2,
	{
	arg msg, time, addr, port;
	[msg].postln;
	},
	'/oscControl/toggle2'
)
);


//Podemos hacer lo mismo con los sliders. El mensaje OSC indica el dispositivo desde donde se está emitiendo el mensaje y el valor de la posición
(
OSCdef(\pruebafader1,
	{
	arg msg, time, addr, port;
	[msg].postln;
	},
	'/oscControl/slider1'
)
);


/*
Vamos a ver cómo podemos utilizar los mensajes OSC con nuestros sintetizadores y rutinas

En primer lugar creemos un sintetizador con SynthDef
Se trata de un sintetizador muy sencillo, una onda trangular con una envolvente percusiva*/
(
SynthDef.new(\sinte1, {
	arg note=60, amp=1;
	var sig, env;
	sig = LFTri.ar(note)!2;
	env = EnvGen.ar(Env.perc(level:amp), doneAction:2);
	sig = sig * env;
	Out.ar(0, sig);
}).add
);


//Implementemos una rutina sencilla con este sintetizador. Esta rutina debe ser activada por el usuario, luego de cada paso de la rutina se encuentra el mensaje .yield. La acción es simple, en cada paso se activa el sintetizador con una nota y una amplitud distinta.
(
a = Routine.new({
	inf.do({
		Synth(\sinte1, [\note, 48.midicps, \amp, 1]).yield;
		Synth(\sinte1, [\note, 60.midicps, \amp, 0.5]).yield;
		Synth(\sinte1, [\note, 72.midicps, \amp, 0.25]).yield;

	})
})
);

//Podemos activar la rutina con la siguiente línea de código.
a.next;


//También podemos recibir un mensaje OSC de nuestra aplicación que active la rutina. Aquí no utilizaremos los argumentos ni la información proveniente del mensaje OSC. Simplemente nos interesa que cada vez que activemos el dispositivo button1, se evalúe la línea de código a.next
(
OSCdef(\testbutton1,
	{
	a.next;
	},
	'/oscControl/button1'
)
);




/*Sigamos investigando en profundidad. Probemos sintetizadores con nuevas envolventes.
Las envolventes que tienen sustain permiten sostener el sonido a una amplitud determinada siempre y cuando el argumento de gate esté activo y sea igual a 1. Cuando ese argumento sea igual a 0, se activará el release de la envolvente*/

Env.asr //Ataque, sustain y release
Env.adsr //Ataque, decaimiento, sustain y release

//Estas envolventes funcionan igual que las vistas en ejemplos anteriores implementadas por EnvGen.
(
x = {
	arg gate=1;

	var sig, env;

	env = EnvGen.kr( Env.asr(1,1,1), gate);

	sig = Dust.ar( rrand(1, 10!50));

	sig = BPF.ar( sig, Array.geom(50, 1, 1.2), 0.1);

	sig = Mix(sig)!2;

	sig = sig * env;

	sig = GVerb.ar(sig);
}.play
)

x.set(\gate, 1);


x.set(\gate, 0);


/*
De la misma manera podemos utilizar un toggle de nuestra aplicación OSC para controlar el argumento de gate de nuestra función.

Hay que tener especial cuidado al indicar qué argumentos de nuestro mensaje OSC vamos a querer utilizar.
Recordemos que el primer argumento que recibimos de nuestro mensaje OSC es el de mensaje, msg que se trata de un Array de dos índices. El primer índice es el nombre del dispositivo/controlador, y el segundo índice es el valor del mensaje.

Si utilizamos un toggle nos indicará primero el nombre del dispositivo toggle y luego su valor, es decir 0 o 1.
Recordemos que en SuperCollider los índices de un Array se cuentan desde el número 0, para indicar el primer valor. El segundo valor tiene índice 1.
Vemos como implementarlo en el código siguiente */
(
OSCdef.new(
	\toggle1,
	{
		arg msg, time, addr, port;
		x.set(\gate, msg[1]);
	},
	'/oscControl/toggle1'
)
);


//Pequeño recordatorio de cómo acceder a los índices de un array!
w = [100, 200, 300, 400, 500];
w[0];
w[1];
w[2];
w[3];
w[4];

//También podemos acceder con el método .at
w.at(1)




//Ejemplo similar al anterior
//CombC pertenece al grupo de los filtros Comb o de peine que utilizan líneas de retardo. Pueden ser utilizados como delays. Los veremos más en detalle más adelante.
//Cambiando los argumentos de GVerb podemos obtener resultados sonoros muy variados
(
y = {
	arg gate=1;
	var env, sig, modu, pan;
	//var sinPanPositions = Array.fill(2, { SinOsc.kr(rrand(0.1,5.0))});
	env = EnvGen.kr( Env.asr(1,1,3), gate);
	sig = Impulse.ar(SinOsc.kr(0.5).range(1,10));

	sig = BPF.ar(sig, Array.series(100, 10, 100), 0.01);
	sig = Mix(sig);

	sig = CombC.ar(sig, 1, SinOsc.kr(1.0).range(0.0,0.5));
	pan = Pan2.ar(sig, LFDNoise0.ar(1.0).range(-1.0,1.0));
	sig = GVerb.ar(pan, 2, 100);
	sig * env;

	//pan = Pan2(sig, SinOsc.kr(0.1));
}.play
)

//Probemos activar esta rutina con OSCdef
(
OSCdef.new(
	\toggle2,
	{
		arg msg, time, addr, port;
		y.set(\gate, msg[1]);
	},
	'/oscControl/toggle2'
)
);
//Ya tenemos nuestra música de lluvia!!!





/*
Complejicemos! Realicemos un sintetizador que tenga una envolvente con sustain para poder activarlo y desactivarlo con uno de los toggles
Utilicemos la superficie con ejes XY para controlar las frecuencias. Podemos realizar dos señales que se modulan entre sí.
Utilicemos los sliders para controlar el la amplitud de nuestro sinte. El sintetizador podría tener un filtro y uno de los sliders podría controlar la frecuencia de corte del filtro.

Pensemos entonces argumentos para amplitud, filtro, gate, posición eje x, posición eje y.

Realicemos un SynthDef para nuestro instrumento */

(
SynthDef.new(\instrumento, {

	arg amp=0, cutoff=50, gate=0, xPos=20, yPos=50;
	var sig, oscX, oscY, env;

	oscX = LFTri.ar(xPos);

	oscY = LFSaw.ar(yPos);

	sig = oscX * oscY;

	sig = LPF.ar(sig, cutoff);

	env = EnvGen.ar(Env.asr, gate);

	sig = sig * env * amp;

	sig = GVerb.ar(sig, 15, 1.5);

	Out.ar(0, sig);

}
).add
);


//Utilicemos una variable para nuestro synth, y así utilizar luego las OSCdef para cambiar los argumentos
z = Synth(\instrumento, [\amp, 0.5, \gate, 1]);
z.set(\gate, 0);


//El toggle3 lo utilizaremos para  el argumento gate de nuestro instrumento
(
OSCdef.new(
	\toggle3,
	{
		arg msg, time, addr, port;
		z.set(\gate, msg[1]);
	},
	'/oscControl/toggle3'
)
);


//El slider1 para controlar la amplitud
(
OSCdef.new(
	\slider1,
	{
		arg msg, tine, addr, port;
		z.set(\amp, msg[1]);
	},
	'/oscControl/slider1'
)
);


//El slider2 para controlar la frencuencia de corte del filtro. Recordemos que el slider por default dará números decimales entre 0.0 y 1.0. Con el método linlin logramos escalar esos valores a un rango de 50 a 7000 (estos valores darán la frecuencia de corte del filtro)
(
OSCdef.new(
	\slider2,
	{
		arg msg, tine, addr, port;
		z.set(\cutoff, msg[1].linlin(0,1, 50, 7000));
	},
	'/oscControl/slider2'
);
)

//Y ahora los OSCdef para la posición de los ejes X e Y de nuestra superficie de control. Nuevamente usamos los métodos linlin para escalar los valores(
(
OSCdef.new(
	\sliderx,
	{
		arg msg, tine, addr, port;
		z.set(\xPos, msg[1].linlin(0,1,20,80).midicps);
	},
	'/oscControl/slider2Dx'
);
)

(
OSCdef.new(
	\slidery,
	{
		arg msg, tine, addr, port;
		z.set(\yPos, msg[1].linlin(0,1,20,50).midicps);
	},
	'/oscControl/slider2Dy'
);
)


