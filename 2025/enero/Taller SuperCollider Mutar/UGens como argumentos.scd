//Qué ocurre si tratamos de asignar una UGen como valor para un argummento??



(
SynthDef(\tam, {
	var sig, modAmp, pan, buf = \buf.ir(0);
	modAmp = SinOsc.kr(\modamp).range(0.0,1.0);
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
        trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 10))
	);
	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));
	Out.ar(0, pan * (modAmp * 0.5));
}).add;
)

(
~routine1 = Routine({
	    Synth(\tam, [buf: ~tam1.bufnum, modAmp: SinOsc.kr(1.0).range(0.0, 1.0)]);
		10.wait;
})
)

~routine1.play;

/*
SuperCollider no acepta UGens como valores de argumentos, por eso el ejemplo anterior da error...

Lo que podemos hacer es colocar la UGen dentro de nuestro SynthDef y sí poner como argumentos los argumentos de esa UGen

Recordemos también que los parámetros que queremos cambiar externamente deben ser declarados como argumentos, no como variables

*/


//Para que funcione en mi ordenador, y en el de cualquiera que quiera probar, voy a cargar el audio por default en un buffer y lo asignaré a la variable que está en la rutina
~tam1 = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");



//Variante de la SynthDef
(
SynthDef(\tam, {

	arg buf, frecmod, minmod, maxmod;

	var sig, modAmp, pan;


	//La UGen SinOsc.kr fue incluida dentro del SynthDef, y sus parámetros fueron convertidos en argumentos, frecuencia y el rango mínimo y máximo
	modAmp = SinOsc.kr(SinOsc.kr(frecmod).range(minmod, maxmod)).range(0.0,1.0);

	//No hace falta declarar todos los nombres de los argumentos, solo si nos salteamos el orden de alguno.
	sig = PlayBuf.ar(1, buf, trigger: Impulse.kr(LFNoise2.kr(1.0).range(1, 10))
	);

	pan = Pan2.ar(sig, LFNoise2.kr(0.5).range(-1.0, 1.0));

	Out.ar(0, pan * (modAmp * 0.5));
}).add;
);


//El SynthDef ya cuenta con un trigger de por sí, por lo que se activará constantemente y no necesita en si mismo una rutina para estar sonando constantemente
Synth(\tam, [\buf, ~tam1.bufnum, \frecmod, 1, \minmod, 0, \maxmod, 1.0]);


//Ahora, en caso de utilizar una rutina siempre es necesario colocar qué cantidad de veces hará ese proceso, es decir incluir un número y asignarle el mensaje .do (ej: 15.do, 3.do, inf.do)

//Al tener un SynthDef con su propio trigger, no es necesario que la rutina active instancias nuevas de nuestro Synth, pero puede resultar interesante guardar nuestro Synth en una variable, y utilizar la rutina para cambiar sus parámetros. Veamos el siguiente ejemplo
x = Synth(\tam, [\buf, ~tam1.bufnum, \frecmod, 1, \minmod, 0, \maxmod, 1.0]);


(
~routine1 = Routine({

	inf.do({
		x.set(\buf, ~tam1.bufnum, \frecmod, rrand(0.1, 10), \minmod, rrand(0, 3.0), \maxmod, rrand(3.0, 10.0));
	1.wait;
});
})
);


~routine1.play;