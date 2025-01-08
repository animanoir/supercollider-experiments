(
{
	var sinOsc, freqMod, ampMod, finalSinOsc, pan;
	ampMod = LFDNoise0.ar(7).range(0, 1);
	freqMod = LFDNoise1.ar(5).range(80,85);
	sinOsc = SinOsc.ar(freq: freqMod);
	pan = Splay.ar( sinOsc, SinOsc.kr(2.0));
	finalSinOsc = pan * ampMod;
	finalSinOsc = GVerb.ar(sinOsc, roomsize: 5) * ampMod/2;
}.play;
)

(
{
	var sinOsc, delayMod,ampMod, fS;
	ampMod = LFDNoise0(10).range(0,1);
	sinOsc = SinOsc.ar(freq: 550, mul: 0.1);

	delayMod = LFDNoise0(10).range(0.1,10);
	fS = Tap.ar(sinOsc)
	fS = sinOsc * ampMod;
}.play
)


















// Esto es un comentario.
/* Estos es
un comentario multínea
*/


// Los () sirven para agrupar código.
(
{
	var sig, pan, modAmp;
	modAmp = LFDNoise0.ar(8).range(0,1);
	sig = SinOsc.ar(freq: modAmp*220, mul: modAmp);
	pan = Splay.ar( sig, SinOsc.kr(2.0));
}.play;
)

(
{
	var sig, pan, modAmp;
	modAmp = LFDNoise0.ar(5).range(0,1);
	sig = SinOsc.ar(freq: modAmp*440, mul: modAmp);
	pan = Pan2.ar( sig, pos: SinOsc.kr(2.0));
}.play;
)

(
{
	var sig, pan, modAmp, delay;
	modAmp = LFDNoise0.ar(10);
	sig = SinOsc.ar(freq: modAmp.range(220,440), mul: modAmp);
	pan = Pan2.ar( sig, pos: modAmp.range(0.0,1.0));
	delay = DelayN.ar(sig, modAmp.range(5.0,10.0),modAmp.range(0.1,5.0));
	sig = pan + delay;
}.play(fadeTime: 5.0);
)


(
{
	var sig, pan, modAmp;
	modAmp = LFDNoise0.ar(10);
	sig = BrownNoise.ar(0.1)*modAmp;
	pan = Pan2.ar(sig, pos: 0.0);
}.play;
)


{BrownNoise.ar(0.1)!2}.play



(
{
var sig, mod1, mod2, mod3;
mod1 = LFDNoise0.ar(1).range(300, 320); // Método "range": Cambia el rango.
mod2 = LFDNoise1.ar(0.3).range(0.2,0.5);
mod3 = LFDNoise0.ar(10);
sig = SinOsc.ar(mod1, 0, mod2)!2;
sig = GVerb.ar(sig)* mod3;
}.play
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