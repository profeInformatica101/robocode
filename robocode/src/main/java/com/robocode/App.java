package com.robocode;

import robocode.control.*;
import robocode.control.events.BattleAdaptor;
import robocode.control.events.BattleCompletedEvent;

public class App {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("❌ Debes especificar al menos 2 bots como argumentos.");
            System.exit(1);
        }

        String robocodeHome = System.getProperty("user.home") + "/robocode";
        RobocodeEngine engine = new RobocodeEngine(new java.io.File(robocodeHome));
        engine.setVisible(true); // Mostrar ventana gráfica (cambiar a false si se desea headless)

        // Escuchar evento de finalización de batalla
        engine.addBattleListener(new BattleAdaptor() {
            @Override
            public void onBattleCompleted(BattleCompletedEvent event) {
                System.out.println("🔚 Batalla terminada.");
                for (robocode.BattleResults result : event.getSortedResults()) {
                    System.out.printf("🤖 %s - %d puntos%n", result.getTeamLeaderName(), result.getScore());
                }
            }
        });

        // Construir lista de bots
        String bots = String.join(",", args);
        RobotSpecification[] selectedRobots = engine.getLocalRepository(bots);

        if (selectedRobots.length < 2) {
            System.err.println("❌ No se encontraron suficientes bots válidos.");
            engine.close();
            System.exit(2);
        }

        // Crear la batalla
        int rounds = 5;
        BattlefieldSpecification battlefield = new BattlefieldSpecification(800, 600);

        BattleSpecification spec = new BattleSpecification(rounds, battlefield, selectedRobots);

        // Ejecutar
        engine.runBattle(spec, true);
        engine.close();
    }
}
