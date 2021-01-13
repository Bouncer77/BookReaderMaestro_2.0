package com.bouncer77.brm.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebController {


    @GetMapping(value = {"/", "index"})
    public String index(Model model) {
        return "/templates/main.html";
    }
}
