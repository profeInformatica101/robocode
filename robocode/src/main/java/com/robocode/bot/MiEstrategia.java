package com.robocode.bot;

public class MiEstrategia {

    public double decidirPotenciaDisparo(double distancia) {
        if (distancia < 100) return 3.0;
        if (distancia < 300) return 2.0;
        return 1.0;
    }

    public int anguloGiroAlChocar() {
        return 90;
    }

    public double retrocesoAlChocar() {
        return 50;
    }
}
