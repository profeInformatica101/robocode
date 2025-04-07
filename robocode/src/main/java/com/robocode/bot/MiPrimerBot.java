package com.robocode.bot;

import robocode.*;

public class MiPrimerBot extends Robot {

    private final MiEstrategia estrategia = new MiEstrategia();
    @Override
    public void run() {
        while (true) {
            ahead(100);
            turnGunRight(360);
            back(100);
            turnGunRight(360);
        }
    }
    @Override
    public void onScannedRobot(ScannedRobotEvent e) {
        double potencia = estrategia.decidirPotenciaDisparo(e.getDistance());
        fire(potencia);
    }
    @Override
    public void onHitWall(HitWallEvent e) {
        back(estrategia.retrocesoAlChocar());
        turnRight(estrategia.anguloGiroAlChocar());
    }
}
