

(
~teAmoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/";
~tePath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/te/";
~amoPath = PathName.new(thisProcess.nowExecutingPath).parentPath++"teamos/amo/";

~te1 = Buffer.read(s, ~tePath++"te1.wav");
~te2 = Buffer.read(s, ~tePath++"te2.wav");
~te3 = Buffer.read(s, ~tePath++"te3.wav");

~amo1 = Buffer.read(s, ~amoPath++"amo1.wav");
~amo2 = Buffer.read(s, ~amoPath++"amo2.wav");
~amo3 = Buffer.read(s, ~amoPath++"amo3.wav");
)

// Te's
// te1
(
x={
	arg te1Rate=1.0;
	var sig;
	sig = PlayBuf.ar(2,~te1.bufnum, loop:1, rate: te1Rate);
	sig = sig * 1.0;
}.play;
)
x.set(\te1Rate, rrand(-1.0,1.0));



// te2
(
{
	var sig;
	sig = PlayBuf.ar(2,~te2.bufnum, loop:1);
	sig = sig * 1.0;
}.play;
)
// te3
(
{
	var sig;
	sig = PlayBuf.ar(2,~te3.bufnum, loop:1);
	sig = sig * 1.0;
}.play;
)

// Amo's
// amo1
(
{
	var sig;
	sig = PlayBuf.ar(2,~amo1.bufnum, loop:1);
	sig = sig * 1.0;
}.play;
)
// amo2
(
{
	var sig;
	sig = PlayBuf.ar(2,~amo2.bufnum, loop:1);
	sig = sig * 1.0;
}.play;
)
// amo3
(
{
	var sig;
	sig = PlayBuf.ar(2,~amo3.bufnum,loop:1);
	sig = sig * 1.0;
}.play;
)