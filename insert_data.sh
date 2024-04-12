#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; 
do
  if [[ $YEAR != "year" ]]; then
    # Récupérer l'ID de l'équipe gagnante
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Si l'équipe gagnante n'est pas trouvée, insérer et récupérer le nouveau team_id
    if [[ -z $WINNER_ID ]]; 
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo "Inserted into teams, $WINNER"
    fi

    # Récupérer l'ID de l'adversaire
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Si l'adversaire n'est pas trouvé, insérer et récupérer le nouveau team_id
    if [[ -z $OPPONENT_ID ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo "Inserted into teams, $OPPONENT"
    fi

    # Insérer le jeu en utilisant les IDs récupérés
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')"
    echo "Inserted into games: $YEAR, $ROUND, Winner: $WINNER ($WINNER_ID), Opponent: $OPPONENT ($OPPONENT_ID)"
  fi
done

