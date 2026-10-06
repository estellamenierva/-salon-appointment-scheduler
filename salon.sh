#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

 echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
echo

SERVICE_MENU=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")
echo "$SERVICE_MENU"

read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

while [[ -z $SERVICE_NAME ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  echo "$SERVICE_MENU"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_PHONE_SQL=$(printf "%s" "$CUSTOMER_PHONE" | sed "s/'/''/g")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")

if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=$(printf "%s" "$CUSTOMER_NAME" | sed "s/'/''/g")
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME_SQL', '$CUSTOMER_PHONE_SQL')" > /dev/null
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
SERVICE_TIME_SQL=$(printf "%s" "$SERVICE_TIME" | sed "s/'/''/g")
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL')" > /dev/null

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
