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
    fluctuateAmplitude = { |interval = 1.0|
        {
            var amp = LFNoise1.kr(interval).range(0.1, 0.9); // Genera un ruido que fluctúa la amplitud entre 0.1 y 0.9
            n.sendMsg("/amplitud", amp); // Enviar la amplitud vía OSC
            SinOsc.ar(440, 0, amp) * 0.5 // Crear un oscilador con la amplitud fluctuante
        }.play;
    };

    // Llamar a la función con el intervalo deseado (por ejemplo, 2 segundos)
    fluctuateAmplitude.value(2.0);
};
)
