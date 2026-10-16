#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
GAME="$SCRIPT_DIR/number_guess.sh"
PSQL=(psql --username=freecodecamp --dbname=number_guess -t --no-align -c)
printf -v TEST_USERNAME 'u%021d' "$$"

cleanup() {
  "${PSQL[@]}" "DELETE FROM users WHERE username = '$TEST_USERNAME';" > /dev/null
}
trap cleanup EXIT

assert_contains() {
  if [[ $1 != *"$2"* ]]; then
    printf 'Expected output to contain: %s\n' "$2" >&2
    exit 1
  fi
}

first_output=$({ printf '%s\n' "$TEST_USERNAME" 'not-an-integer' 0 1001; seq 1 1000; } | "$GAME")
assert_contains "$first_output" "Welcome, $TEST_USERNAME! It looks like this is your first time here."
assert_contains "$first_output" 'That is not an integer, guess again:'
assert_contains "$first_output" "It's higher than that, guess again:"
assert_contains "$first_output" "It's lower than that, guess again:"
first_result=$(printf '%s\n' "$first_output" | sed -n 's/^You guessed it in \([0-9][0-9]*\) tries\. The secret number was \([0-9][0-9]*\)\. Nice job!$/\1|\2/p')
IFS='|' read -r first_tries first_secret <<< "$first_result"
[[ $first_tries -eq $((first_secret + 3)) ]]

second_output=$(printf '%s\n' "$TEST_USERNAME" "$(seq 1 1000)" | "$GAME")
assert_contains "$second_output" "Welcome back, $TEST_USERNAME! You have played 1 games, and your best game took $first_tries guesses."
second_result=$(printf '%s\n' "$second_output" | sed -n 's/^You guessed it in \([0-9][0-9]*\) tries\. The secret number was \([0-9][0-9]*\)\. Nice job!$/\1|\2/p')
IFS='|' read -r second_tries _ <<< "$second_result"

expected_best=$first_tries
if (( second_tries < expected_best )); then
  expected_best=$second_tries
fi
stored_data=$("${PSQL[@]}" "SELECT games_played, best_game FROM users WHERE username = '$TEST_USERNAME';")
[[ $stored_data == "2|$expected_best" ]]

printf 'Game integration checks passed.\n'