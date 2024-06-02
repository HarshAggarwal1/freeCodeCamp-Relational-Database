#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get WINNER_ID and OPPONENT_ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if WINNER_ID not found
    if [[ -z $WINNER_ID ]]
    then 
      # insert the WINNER in teams
      INSERT_WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNER_ID == "INSERT 0 1" ]]
      then
        echo Added team $WINNER to the teams table
      fi
      # get WINNER_ID
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # if OPPONENT_ID not found
    if [[ -z $OPPONENT_ID ]]
    then 
      # insert the OPPONENT in teams
      INSERT_OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OPPONENT_ID == "INSERT 0 1" ]]
      then
        echo Added team $OPPONENT to the teams table
      fi
      # get OPPONENT_ID
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # add data to the games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Added game event "$YEAR, "$ROUND", $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS" into games
    fi

  fi
done