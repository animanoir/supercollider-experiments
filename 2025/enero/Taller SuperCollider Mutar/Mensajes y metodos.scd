s.boot;
s.makeWindow;
s.quit;

//.reciprocal se puede aplicar a un número, y lo que hace este método es dividir 1 por el número en cuestión
//Ejemplos
2.reciprocal    //es igual a 1/2
8.reciprocal    //es igual a 1/8
0.5.reciprocal  //es igual a 1/0.5


//.sqrt saca la raíz cuadrada de un númer
9.sqrt
25.sqrt
298.sqrt





//Graficar funciones
//.poll nos da los valores de la UGen a la que se lo indiquemos. En su argumento podemos indicar la frecuencia con la que queremos que nos devuelva los valores que está midiendo.

{Line.kr(10, 100, 10, doneAction:2).poll(20)}.play
{SinOsc.ar(0.5).poll(10)}.play



//.fold hace que se espeje la señal, que se doble como si dobláramos un papel... recibe dos argumentos o no?
//Ej1
(
{
	SinOsc.ar(1).fold(-1, 0)
}.plot(2)
);

//Ej2
(
{
	SinOsc.ar(1).fold(0, 1)
}.plot(2)
);

//Ej3
(
{
	SinOsc.ar(1).fold(0, 0.5)
}.plot(2)
);





//.clip recorta todo debajo de determinado umbral. Puede recibir números negativos o positivos e indicar límite inferior y superior
//Ej1
(
{
	SinOsc.ar(1).clip(-1, 0)
}.plot(2)
);

//Ej2
(
{
	SinOsc.ar(1).clip(-0.3, 0.5)
}.plot(2)
);





//.clip2 recorta los picos, recibe solo números positivos, tiene un solo argumento que indica cuánto va a recortar a partir del punto de reposo
//Ej1
(
{
	SinOsc.ar(1).clip2(0.3)
}.plot(2)
);

//Ej2
(
{
	SinOsc.ar(1).clip2(0.7)
}.plot(2)
);






//.round redondea el valor de la función al argumento que le proporcionemos.
//Ej1
(
{
	SinOsc.ar(1).round(0.1)
}.plot(2)
);

//Ej1
(
{
	SinOsc.ar(1).round(0.3)
}.plot(2)
);


//.range escala los valores de la función al rango que le demos
//Ej1
(
{
	SinOsc.ar(1).range(15, 30)
}.plot(2)
);

//Ej1
(
{
	SinOsc.ar(1).range(100, 200)
}.plot(2)
);



//.ampdb cómo se utiliza?
//Ej1
(
{
	SinOsc.ar(1)
}.plot(2)
);
