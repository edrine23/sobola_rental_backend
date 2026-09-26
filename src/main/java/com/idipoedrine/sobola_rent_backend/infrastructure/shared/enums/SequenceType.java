package com.idipoedrine.sobola_rent_backend.infrastructure.shared.enums;

import lombok.Getter;

@Getter
public enum SequenceType {
    USER_NUMBER("user_number_seq", "SBL", 6),
    STAFF_NUMBER("staff_number_seq", "STF", 6),
    PROPERTY_NUMBER("property_number_seq", "PRP", 6),
    RECEIPT_NUMBER("receipt_number_seq", "RCP", 6),
    CASE_NUMBER("case_number_seq", "CASE", 5);

    private final String sequenceName;
    private final String prefix;
    private final int digitWidth;

    SequenceType(String sequenceName, String prefix, int digitWidth) {
        this.sequenceName = sequenceName;
        this.prefix = prefix;
        this.digitWidth = digitWidth;
    }
}