package com.idipoedrine.sobola_rent_backend.infrastructure.shared.utility;

import com.idipoedrine.sobola_rent_backend.infrastructure.shared.enums.SequenceType;
import lombok.AllArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.time.Year;

@AllArgsConstructor
@Component
public class SequenceGenerator {
    private final JdbcTemplate jdbcTemplate;

    public String generate(SequenceType type) {
        Long value = jdbcTemplate.queryForObject(
                "SELECT nextval(?::regclass)", Long.class, type.getSequenceName());

        String digitFormat = "%0" + type.getDigitWidth() + "d";
        return type.getPrefix() + "-" + Year.now().getValue() + "-" + String.format(digitFormat, value);
    }
}
