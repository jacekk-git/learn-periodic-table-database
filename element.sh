#!/usr/bin/bash

if [[ "$1" == "" ]]
then
  echo Please provide an element as an argument.
  exit 0
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

re='^[1-9][0-9]*$'

if [[ "$1" =~ $re ]] ; then
# find element by atomic number
   ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
else
   ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
fi

if [[ "$ATOMIC_NUMBER" == "" ]]
then
  echo I could not find that element in the database.
  exit 0
fi

QUERY=$(cat <<-END
select e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
from elements e
inner join properties p on p.atomic_number = e.atomic_number
inner join types t on t.type_id = p.type_id
where e.atomic_number = $ATOMIC_NUMBER;
END
)

DETAILS=$($PSQL "$QUERY")

NAME=$(echo "$DETAILS" | cut -d"|" -f1)
SYMBOL=$(echo "$DETAILS" | cut -d"|" -f2)
TYPE=$(echo "$DETAILS" | cut -d"|" -f3)
MASS=$(echo "$DETAILS" | cut -d"|" -f4)
MELTING=$(echo "$DETAILS" | cut -d"|" -f5)
BOILING=$(echo "$DETAILS" | cut -d"|" -f6)

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
