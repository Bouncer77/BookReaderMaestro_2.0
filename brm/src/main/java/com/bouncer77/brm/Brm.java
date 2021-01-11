package com.bouncer77.brm;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class Brm {

    public static void main(String[] args) {
        SpringApplication.run(Brm.class, args);
    }

    /**
     * Метод возвращает CommandLineRunnerкомпонент , который автоматически запускает код при запуске приложения.
     */
    @Bean
    public CommandLineRunner demo() {
        return (args) -> {
            System.out.println("Hello, World!");
        };
    }
}
