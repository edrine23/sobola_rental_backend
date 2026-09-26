CREATE TABLE refresh_tokens (
                                id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                user_id     UUID        NOT NULL,
                                token_hash       TEXT        NOT NULL UNIQUE,
                                revoked     BOOLEAN     NOT NULL DEFAULT FALSE,
                                expires_at  TIMESTAMP   NOT NULL,
                                created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
                                CONSTRAINT fk_rt_user FOREIGN KEY (user_id) REFERENCES users(id)
);