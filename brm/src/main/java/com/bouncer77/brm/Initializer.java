package com.bouncer77.brm;

import com.bouncer77.brm.repository.QuestionnaireRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Collections;
import java.util.stream.Stream;

@Component
class Initializer implements CommandLineRunner {

    private final QuestionnaireRepository repository;

    public Initializer(QuestionnaireRepository repository) {
        this.repository = repository;
    }

    @Override
    public void run(String... strings) {

        repository.createTenantOrSomething();

        //repository.findAll().forEach(System.out::println);
    }
}
