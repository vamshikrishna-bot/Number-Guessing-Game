#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

printf 'Enter your username: '
IFS= read -r USERNAME || exit 0
SQL_USERNAME=${USERNAME//\'/\'\'}
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$SQL_USERNAME';")

if [[ -n $USER_DATA ]]; then
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  printf 'Welcome back, %s! You have played %s games, and your best game took %s guesses.\n' "$USERNAME" "$GAMES_PLAYED" "$BEST_GAME"
else
  printf 'Welcome, %s! It looks like this is your first time here.\n' "$USERNAME"
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$SQL_USERNAME', 0, 0);" > /dev/null
fi

printf 'Guess the secret number between 1 and 1000:\n'
IFS= read -r GUESS || exit 0
NUMBER_OF_GUESSES=1

while [[ ! $GUESS =~ ^[0-9]+$ ]] || (( 10#$GUESS != SECRET_NUMBER )); do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    printf 'That is not an integer, guess again:\n'
  elif (( 10#$GUESS < SECRET_NUMBER )); then
    printf "It's higher than that, guess again:\n"
  else
    printf "It's lower than that, guess again:\n"
  fi
  IFS= read -r GUESS || exit 0
  ((NUMBER_OF_GUESSES += 1))
done

$PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game = 0 OR $NUMBER_OF_GUESSES < best_game THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE username = '$SQL_USERNAME';" > /dev/null
printf 'You guessed it in %s tries. The secret number was %s. Nice job!\n' "$NUMBER_OF_GUESSES" "$SECRET_NUMBER"