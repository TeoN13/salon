#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    # display available services
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # get service that user wants
  read SERVICE_ID_SELECTED
  # check if input was NOT a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please select a valid service. What would you like today?"
  else
  # check if one of the listed services was picked
  SERVICE_ID_SELECTED_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED_ID ]]
  then
    # send back to start
    MAIN_MENU "Please select one of the listed services. What would you like today?"
    else
    # make appointment
    APPOINTMENT_MENU $SERVICE_ID_SELECTED_ID
  fi
  fi
}

APPOINTMENT_MENU(){
  # $1 = service_id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//')
  echo "You've selected: $SERVICE_NAME_FORMATTED"

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # check if record exists
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # insert customer into db
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
    NAME_NO=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    CUSTOMER_NAME=$(echo $NAME_NO | sed -E 's/^ *| *$//')
  fi
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU "Welcome! How can I help you?"
