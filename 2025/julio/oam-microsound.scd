s.makeWindow;
s.options.sampleRate = 48000;
a = Scale.major;
Server.supernova

(
play(
	{
		SinOsc.ar(LFNoise0.kr(12!2, 600, 1000), 0.0, 0.1)
	}
)
)


play({RLPF.ar(Dust.ar([3, 5]), LFNoise1.ar(1/[3/1], 1500, 1600), 0.02)})

(
play({
var sines = 10, speed = 2;
Mix.fill(sines,
{arg x;
Pan2.ar(
SinOsc.ar({exprand(100.0, 1200.0).round(0.01)}!2,
mul: max(0,
LFNoise2.kr(speed) +
Line.kr(-1, 1, 100)
)
), rand2(1.0))})/sines})
)


{Impulse.ar(XLine.kr(12, 48, 6)) * 0.1 ! 2}.play; // up
{Impulse.ar(XLine.kr(48, 12, 6)) * 0.1 ! 2}.play; // down
{Impulse.ar(MouseX.kr(12, 48, 1)) * 0.1 ! 2}.play; // by
cursor

rand(100)
/* Exponential random choices are useful in music (for
frequency), since successive musical intervals (perceived by humans to be equal) are
in reality exponentially larger gaps. (A4 to A5 is 440 to 880, a difference of 880, but
A5 to A6 is 880 to 1760, twice as far.)
*/
{exprand(10, 100).round(0.01)}!20 //!20 means evaulate 20 times.

thisThread.randSeed = 666; //changes the random seed so we can have the same random numbers.

dup("echo", 100);
round([3.141], 5.9265, 358.98, 0.01)
sort([23, 54, 678, 1, 21, 91, 34, 78]) // orders the numbers
round(dup({exprand(1, 10)}, 100, 0.1))
sort(round(dup({exprand(1,10)},100,0.1)))

(
play(
{
CombN.ar(
SinOsc.ar(
midicps(
LFNoise1.ar(3, 10,
LFSaw.ar([5, 5.123], 0, 3, 80)
)
),
0, 0.4),
1, 0.1, 2)
}
)
)