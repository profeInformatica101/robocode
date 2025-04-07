package com.robocode.bot;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;


class MiEstrategiaTest {

    MiEstrategia estrategia = new MiEstrategia();

    @Test
    void testPotenciaDisparo() {
        assertEquals(3.0, estrategia.decidirPotenciaDisparo(50));
        assertEquals(2.0, estrategia.decidirPotenciaDisparo(150));
        assertEquals(1.0, estrategia.decidirPotenciaDisparo(400));
    }

    @Test
    void testRetrocesoYAngulo() {
        assertEquals(50, estrategia.retrocesoAlChocar());
        assertEquals(90, estrategia.anguloGiroAlChocar());
    }
}

