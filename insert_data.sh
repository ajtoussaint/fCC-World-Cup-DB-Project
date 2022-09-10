#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Clear data from the DB to prevent errors
echo "$($PSQL "TRUNCATE TABLE games,teams")"

#Get Data from the games.csv file

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
#neglect the first line of the file
if [[ $YEAR != year ]]
then
  #If the winner is a team that has not been used before update the teams DB
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
  #if the winner doesnt already exist
  if [[ -z $WINNER_ID ]]
  then
    #insert the winner
    INSERT_WINNER="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
    if [[ $INSERT_WINNER = 'INSERT 0 1' ]]
    then
      #display confirmation
      echo Inserted $WINNER into teams DB
    fi #clsoe of insert 0 1
    #get new ID
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
  fi # close of -z

  #If the opponent is not in the teams DB add them to the teams DB
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
  #if the opponent doesnt already exist
  if [[ -z $OPPONENT_ID ]]
  then
    #insert the opponent
    INSERT_OPPONENT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
    if [[ $INSERT_OPPONENT = 'INSERT 0 1' ]]
    then
      #display confirmation
      echo Inserted $OPPONENT into teams DB
    fi #clsoe of insert 0 1
    #get new ID
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
  fi # close of -z

  #Add the game information and the winner and opponent ID from the teams DB to the games DB
  echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"

  fi #end != year if
done #end most outer while loop
