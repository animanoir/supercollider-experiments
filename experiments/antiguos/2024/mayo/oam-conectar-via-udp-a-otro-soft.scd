b = NetAddr.new("127.0.0.1", 666)
b.sendMsg("Hola, vengo desde los reinos de SuperCollider");

(
"El ranchero salvaje".postln;
"Este es un mensaje enviado a la consola de SC".postln;
)

// La s. es como para acceder al servidor base de SC.

s.quit;
s.boot;
s.options.sampleRate = 48000;
s.options.device = "Altavoces (Focusrite Usb Audio)";
s.options.inDevice = "Analogue 1 + 2 (Focusrite Usb Audio)";
ServerOptions.devices;


oS.value;

f = { "Evalúa esta función...".postln; 2 + 3; };
f.value;

// Puedo poner un `arg` antes de todo para decir que esta función puede aceptar argumentos.
f = { arg n; n.rand; };
f.value(0.5);
var oS = { [SinOsc.ar(440,0,f.value(0.1)), SinOsc.ar(442,0,f.value(0.2))] }.play;

4.class;
SinOsc.class;


~variableGlobal = 5;
~variableGlobal.isNil;

var num;
num.isFloat;

num = 5;
var x;
x = 5;
x.postln;
x.isInteger;
(
var estaVariable;
estaVariable = 6;
cacaAguada.postln;
)

(
    var estaVariable;
    estaVariable = 6;
    estaVariable.postln; // Esto imprimirá 6 en la ventana de post
)

(
var arrayNumbers;
arrayNumbers = [1,2,3,4,5];
arrayNumbers.dup(10);
arrayNumbers ! 2; //Esto sirve para duplicar el arreglo—el ! es una abreviación de .dup
)

(
{
	var source, source2, limited;

	// Generar una señal de ruido blanco
	source = WhiteNoise.ar(0.1);
	source2 = PinkNoise.ar(0.1);

	limited = Limiter.ar(source, 0.9, 0.01);

	Out.ar(0, limited);
}.play;

)
