package com.robocode.bot;

import robocode.Robot;

public class MiRobotSencillo extends Robot {
    public void run() {
        while (true) {
            ahead(100);
            turnRight(90);
        }
    }
}