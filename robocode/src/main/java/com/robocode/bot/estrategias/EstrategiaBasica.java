package com.robocode.bot.estrategias;

import robocode.*;

/**
 * Clase que contiene estrategias básicas para propósitos educativos
 * 
 * Niveles de aprendizaje:
 * 1. Movimiento básico
 * 2. Disparo básico
 * 3. Reacciones básicas
 */
public class EstrategiaBasica {
    
    /**
     * Movimiento básico: Avanzar y girar
     */
    public void movimientoBasico(Robot robot) {
        robot.ahead(100);  // Avanzar 100 píxeles
        robot.turnRight(90); // Girar 90 grados
    }
    
    /**
     * Movimiento circular: Patrón más complejo
     */
    public void movimientoCircular(Robot robot) {
        robot.ahead(50);
        robot.turnRight(30);
        robot.ahead(50);
        robot.turnLeft(30);
    }
    
    /**
     * Cálculo básico de potencia de disparo
     * @param distancia Distancia al enemigo
     * @return Potencia del disparo (1-3)
     */
    public double calcularPotenciaDisparo(double distancia) {
        // Ejemplo didáctico de estructura condicional
        if (distancia < 100) {
            return 3.0; // Máxima potencia cerca
        } else if (distancia < 250) {
            return 2.0; // Potencia media
        } else {
            return 1.0; // Potencia mínima lejos
        }
    }
}