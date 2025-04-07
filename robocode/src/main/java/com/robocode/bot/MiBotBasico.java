package com.robocode.bot;

import robocode.AdvancedRobot;
import robocode.ScannedRobotEvent;
import robocode.HitWallEvent;
import java.awt.Color;

/**
 * Bot básico para aprender Java con Robocode.
 */
public class MiBotBasico extends AdvancedRobot {

    private int direccion = 1;

    public void run() {
        // Personalización visual del bot
        setBodyColor(Color.blue);
        setGunColor(Color.black);
        setRadarColor(Color.cyan);

        // Ajustes para controlar arma y radar por separado
        setAdjustGunForRobotTurn(true);
        setAdjustRadarForGunTurn(true);

        while (true) {
            setTurnRadarRight(360); // Radar gira constantemente
            setAhead(100 * direccion);
            setTurnRight(20);
            execute();
        }
    }

    @Override
    public void onScannedRobot(ScannedRobotEvent e) {
        double distancia = e.getDistance();
        double potencia;

        if (distancia < 100) {
            potencia = 3;
        } else if (distancia < 300) {
            potencia = 2;
        } else {
            potencia = 1;
        }

        // Gira el arma hacia el enemigo y dispara
        double anguloDisparo = getHeading() + e.getBearing() - getGunHeading();
        setTurnGunRight(anguloDisparo);
        if (getGunHeat() == 0 && Math.abs(getGunTurnRemaining()) < 10) {
            setFire(potencia);
        }
    }

    @Override
    public void onHitWall(HitWallEvent e) {
        direccion *= -1;
        setBack(100);
        setTurnRight(45);
    }
}
