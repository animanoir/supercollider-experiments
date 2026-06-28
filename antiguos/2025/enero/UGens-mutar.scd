//UGens para producir sonido


/*Osciladores
Son generadores de formas de ondas periódicas. Entre sus argumentos se encuentra la frecuencia, la fase, y el mul y el add. Podemos considerar mul lo que controla la amplitud, y el add el offset que será el punto de reposo de la función. Por default el mul es 1 y el add es 0, por lo que los osciladores dan valores entre 1 y -1.
*/

//SinOsc
SinOsc //Produce señales sinusoidales, tonos puros

SinOsc.ar(frecuencia, fase, mul, add)

{ SinOsc.ar( 440, 0, 0.1, 0)}.play

//El argumento fase en SinOsc lo podemos indicar en fracciones del número pi
{SinOsc.kr(1, 0pi, 50, 100)}.plot(2) // El 1 es un ciclo/hZ por segundo.
{SinOsc.kr(1, 0.5pi)}.plot(1)
{SinOsc.kr(1, 1pi)}.plot(1)
{SinOsc.kr(1, 1.5pi)}.plot(1)

//LFTri
LFTri //Produce señales triangulares

LFTri.ar(frecuencia, iphase, mul, add)

{LFTri.ar(440, 0, 0.01, 0)}.play

//El argumento iphase lo podemos expresar en valores entre 0 y 4, siendo 0 y 4 el mismo punto de partida
{LFTri.ar(1, 0, 1, 0)}.plot(1)
{LFTri.ar(1, 1, 1, 0)}.plot(1)
{LFTri.ar(1, 2, 1, 0)}.plot(1)
{LFTri.ar(1, 3, 1, 0)}.plot(1)


//Pulse y LFPulse, ambos producen ondas cuadradas
Pulse //de banda limitada
LFPulse //no es banda limitada

Pulse.ar(frecuencia, ancho, mul, add)
LFPulse.ar(frecuencia, iphase, ancho, mul, add)

{Pulse.ar(440, 0.5, 0.1, 0)}.play
{LFPulse.ar(440, 0, 0.5, 0.1, 0)}.play

//LFPulse, iphase y width. width marca el ancho del pulso, siendo 0.5 partes iguales. iphase se expresa en valores de 0 a 1
{LFPulse.ar(1, 0, 0.5, 1, 0)}.plot(1)
{LFPulse.ar(1, 0.25, 0.5, 1, 0)}.plot(1)
{LFPulse.ar(1, 0.5, 0.5, 1, 0)}.plot(1)
{LFPulse.ar(1, 0.75, 0.5, 1, 0)}.plot(1)


//Saw y LFSaw, ambos producen ondas dientes de sierra
Saw //banda limitada
LFSaw //banda no limitada

{LFSaw.ar(440, 0, 0.01, 0)}.play

{LFSaw.ar(1, 0, 1, 0)}.plot(1)




/*Generadores de ruido
Generan ruido con distinto tipo de funciones, cada uno da una función aleatoria.
*/
WhiteNoise //Produce ruido parejo en intensidad en todo el espectro
PinkNoise //Produce ruido con una caída de 3dB por octava
BrownNoise //Produce ruido con una caída de 6dB por octava
ClipNoise //Produce aleatoriamente valores que son 1 o -1

{ClipNoise.ar(0.1)}.play
{WhiteNoise.ar(0.1)}.play
{PinkNoise.ar(0.1)}.play
{BrownNoise.ar(0.1)}.play




/*Generadores de ruido de baja frecuencia
Se parecen a los generadores de ruido en cuanto a que dan funciones aleatorias, pero en ellos se puede percibir una frecuencia.
*/
LFDClipNoise
LFDNoise0
LFDNoise1
LFDNoise3



/*Generadores de impulsos
Generan impulsos de un solo sample, es decir clic.
*/
Impulse
Dust




/*Filtros
Estas UGens no generan sonido sino que lo modifican. Filtran parte del espectro sonoro y dejan pasar el espectro sonoro seleccionado. Entre sus argumentos se encuentra la fuente a filtrar, la frecuencia de corte, el mul y el add.
*/
LPF
HPF
BPF
BRF

RLPF
RHPF

Ringz




/*Manipulación multicanal
Estas UGens nos permiten manipular las señales ya sea colocando señales en el campo stereo, o reduciendo las señales a un solo canal.
*/
Pan2
Splay
Mix




/*Envolventes
Las envolventes describen una curva de valores en el tiempo con principio y fin. Normalmente están asociados con la evolución de la amplitud de una señal en el tiempo, aunque pueden ser utilizadas para controlar la frecuencia, filtros o cualquier parámetro que se desee.
*/
Line
XLine

EnvGen
Env
Env.perc
Env.sine
Env.triangle
Env.adsr
Env.asr
