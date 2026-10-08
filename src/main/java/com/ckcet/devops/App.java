package com.ckcet.devops;

import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;

public class App {
    public static void main(String[] args) {
        int port = getPort();

        Javalin app = Javalin.create(config -> {
            config.staticFiles.add("/public", Location.CLASSPATH);
        }).start(port);

        app.get("/api/health", ctx -> {
            ctx.contentType("application/json");
            ctx.result("{\"status\":\"UP\",\"app\":\"XO Arena\",\"version\":\"1.0.0\"}");
        });

        System.out.println("XO Arena backend running on http://localhost:" + port);
    }

    private static int getPort() {
        String envPort = System.getenv("PORT");
        if (envPort != null && !envPort.trim().isEmpty()) {
            try {
                return Integer.parseInt(envPort.trim());
            } catch (NumberFormatException e) {
                System.err.println("Invalid PORT environment variable (" + envPort + "), defaulting to 8080");
            }
        }
        return 8080;
    }
}
