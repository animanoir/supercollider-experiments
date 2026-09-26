// Conectar vía OSC SuperCollider con Max/MSP:
n = NetAddr.new("127.0.0.1", 666);
n.sendMsg("/hola", "Hola, vengo desde los reinos de SuperCollider");

// Reiniciar el servidor
s.quit;
s.boot;

(
s.waitForBoot {
    // Definir la función que fluctúa la amplitud
    var fluctuateAmplitude;
    fluctuateAmplitude = { |interval = 20.0|
        {

            var amp = LFNoise2.kr(interval).range(0.0, 1.0); // Genera un ruido que fluctúa la amplitud entre 0.1 y 0.5
			SendReply.kr(Impulse.kr(interval), '/sendAmp', [amp]); // Enviar la amplitud vía OSC
			// Crear un oscilador con la amplitud fluctuante
            Pan2.ar(SinOsc.ar(amp * 500, 0, amp))
         }.play;
    };

    // Llamar a la función con el intervalo deseado (por ejemplo, 2 segundos)
    fluctuateAmplitude.value(20.0);

    // Crear una función que maneje el mensaje recibido
    OSCFunc({
        arg msg;
        var amp = msg[3]; // Obtener el valor de la amplitud del mensaje
        n.sendMsg("/amplitud", amp); // Enviar la amplitud vía OSC a Max/MSP
    }, '/sendAmp').permanent_(true); // Asegurarse de que esta función permanezca activa
};
)
