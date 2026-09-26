// Funciones de arreglos
[1, 2, 3, 4, "hello"].scramble;
[1, 2, 3, 4, "hello"].mirror;
[1, 2, 3, 4].reverse + 10;
// convert midi to frequency in Hz
[60, 62, 64, 65, 67, 69, 71].midicps.round(0.1)

rand(1000.0).dup(5);
// picks a number, duplicates it
{rand(1000.0)}.dup(5);
// duplicates the function of picking a number
{rand(1000.0)}.dup(5).round(0.1); // all of the above, then round
// essentially, this (which has a similar result)
[rand(1000.0), rand(1000.0), rand(1000.0), rand(1000.0), rand(1000.0)]

if(100 > 500, { "very true".postln }, { "very false".postln });

// case

(
~num = -2;
case
{~num == 0} {"WOW".postln}
{~num == 1} {"ONE!".postln}
{~num < 0} {"negative number!".postln}
{true} {"last case scenario".postln};
)

f = {arg a, b; ["a plus b", a+b, "a times b", a*b].postln}; // define function
f.value(3, 7); // now you can give any two numbers as arguments to the function

~sillyRand = rrand(0, 10); // not a function
~sillyRand.value; // evaluate several times
~sillyRand2 = {rrand(0, 10)}; // a function
~sillyRand2.value; // evaluate several times