#!/bin/bash


MAIN_MENU() {
echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?"
PSQL="psql --username=postgres --dbname=salon --tuples-only -c"
  RENDER=$($PSQL "SELECT service_id, name FROM services")
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo "$RENDER" | while read SERVICE_ID BAR SERVICE
  do
    if [[ $SERVICE_ID ]]; then
      echo "$SERVICE_ID) $SERVICE"
    fi
  done

  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -e 's/^ *//g' -e 's/ *$//g')

  if [[ -z $SERVICE_SELECTED ]]; then
    MAIN_MENU ""

  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID" | sed -e 's/^ *//g' -e 's/ *$//g')

    echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]; then
      echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\nSorry, something went wrong. Please try again."
    fi
  
  fi
}

MAIN_MENU