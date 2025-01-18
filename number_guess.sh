#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

WELCOME_USER() {
  # Prompt user for username
  echo "Enter your username:"
  read USERNAME

  # Check if the username exists in the database
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

  # If the user has not played before
  if [[ -z $USER_INFO ]]
  then
      # If this is the first time the user is here
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      # Insert the user into the database
      INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  else   
      # Parse the user info
      IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

GUESS_GAME() {

  # Start the guessing game
  echo "Guess the secret number between 1 and 1000:"

  # Loop to get guesses until the correct one is made
  while true
  do
      read GUESS
      ((NUMBER_OF_GUESSES++))

      # Check if the input is an integer
      if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
          echo "That is not an integer, guess again:"
          continue
      fi

      # Check if the guess is correct
      if (( GUESS == SECRET_NUMBER )); then
          echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
          break
      elif (( GUESS < SECRET_NUMBER )); then
          echo "It's higher than that, guess again:"
      else
          echo "It's lower than that, guess again:"
      fi
  done
}

UPDATE_USER_INFORMATION() {
  # Update the user's game statistics
  USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_STATS"
  NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

  # Update the best_game if necessary
  if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      UPDATE_USER=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  else
      UPDATE_USER=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED WHERE username = '$USERNAME'")
  fi
}

WELCOME_USER

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

GUESS_GAME

UPDATE_USER_INFORMATION