package com.hilgo.rotax;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class RotaxApplication {

    public static void main(String[] args) {
        SpringApplication.run(RotaxApplication.class, args);
    }

}
