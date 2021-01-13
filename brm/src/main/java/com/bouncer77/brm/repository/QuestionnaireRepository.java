package com.bouncer77.brm.repository;

import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.stereotype.Repository;

@Repository
public interface QuestionnaireRepository {
    @Procedure(value = "brm_api.ui_read_questionnaires")
    void createTenantOrSomething(/*@Param("t_name") String tNameOrSomething*/);
}