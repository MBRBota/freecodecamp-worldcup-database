#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\n~~~ World Cup Data Insertion ~~~\n"

TRUNCATE="$($PSQL "TRUNCATE teams, games RESTART IDENTITY")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WIN_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    if [[ -z $WIN_ID ]]
    then
      TEAM_INSERT="$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")"
      echo "Inserted $WINNER into teams table."
      WIN_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    fi

    OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    if [[ -z $OPP_ID ]]
    then
      TEAM_INSERT="$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")"
      echo "Inserted $OPPONENT into teams table."
      OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    fi

    GAME_INSERT="$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS)")"
    echo "Inserted game:  $YEAR $ROUND: $WINNER - $OPPONENT  $WIN_GOALS-$OPP_GOALS"
  fi
done
