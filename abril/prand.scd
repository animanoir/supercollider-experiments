(Pbind(
 \freq, Prand([140, 550, 660, 770, 880], inf),
 \dur, Prand([0.1, 0.21 ,0.2, 0.4, 0.5], inf),
 \amp, Prand([0.1, 0.1 ,0.2, 0.2, 0.3], inf),
 \legato, 0.1
).play)

s.boot;
s.quit;