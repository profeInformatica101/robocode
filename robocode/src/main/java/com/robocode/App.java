package com.robocode;

import java.io.File;

import robocode.BattleResults;
import robocode.control.*;
import robocode.control.events.BattleAdaptor;
import robocode.control.events.BattleCompletedEvent;

/**
 * Clase principal para ejecutar una batalla Robocode desde código Java.
 */
public class App {
    public static void main(String[] args) {
        // 📁 Ruta Robocode
        String robocodeHome = System.getProperty("user.home") + "/robocode";
        File robocodeDir = new File(robocodeHome);

        // 🧠 Inicializa motor de Robocode
        RobocodeEngine engine = new RobocodeEngine(robocodeDir);

        // 💡 Comprobar si hay entorno gráfico
        boolean guiDisponible = System.getenv("DISPLAY") != null;
        engine.setVisible(guiDisponible);

        // 📊 Listener para mostrar resultados
        engine.addBattleListener(new BattleAdaptor() {
            @Override
            public void onBattleCompleted(BattleCompletedEvent e) {
                System.out.println("🔚 Batalla terminada.");
                for (BattleResults result : e.getSortedResults()) {
                    System.out.printf("🤖 %s - %d puntos%n", result.getTeamLeaderName(), result.getScore());
                }
                engine.close();
                System.exit(0);
            }
        });

        // ⚙️ Configuración de la batalla
        RobotSpecification[] robots = engine.getLocalRepository("com.robocode.bot.MiPrimerBot,sample.SpinBot");
        BattlefieldSpecification battlefield = new BattlefieldSpecification(800, 600);
        BattleSpecification battle = new BattleSpecification(3, battlefield, robots);

        // 🚀 Ejecutar batalla
        engine.runBattle(battle, true);
    }
}
