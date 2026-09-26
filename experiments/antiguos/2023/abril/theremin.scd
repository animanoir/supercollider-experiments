{ SinOsc.ar(MouseX.kr(40, 10000, 1), 0, 0.1) }.scope;
{ SinOsc.ar(MouseX.kr(500, 10000, 1).poll, 0, 0.1) }.play;

{ SinOsc.ar([440, 800]) }.plot.play;

{SinOsc.ar}.plot;

// just watch the Post window (no sound)
{SinOsc.kr(1).poll}.play;
// hit ctrl+period, then evaluate the next line:
{LFPulse.kr(1).poll}.play;

{LFNoise0.ar(5).poll}.play;

{Pan2.ar(LFPulse.ar(2))}.play

s.quit;