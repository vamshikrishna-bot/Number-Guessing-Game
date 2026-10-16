\connect postgres
DROP DATABASE IF EXISTS number_guess;
CREATE DATABASE number_guess OWNER freecodecamp;
\connect number_guess

CREATE TABLE public.users (
    username VARCHAR(22) PRIMARY KEY,
    games_played INTEGER NOT NULL DEFAULT 0,
    best_game INTEGER NOT NULL
);

ALTER TABLE public.users OWNER TO freecodecamp;