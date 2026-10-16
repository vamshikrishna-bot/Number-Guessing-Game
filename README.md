# Number Guessing Game

The game uses Bash and PostgreSQL. It connects as the `freecodecamp` database user.

## Set up the database

Run the restore script from the project directory:

```sh
psql --username=freecodecamp --dbname=postgres -f number_guess.sql
```

This recreates the `number_guess` database and removes any saved game history.

## Play

```sh
./number_guess.sh
```

## Run the integration test

```sh
./test_number_guess.sh
```