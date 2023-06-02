#!/bin/bash

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

echo -e "\n~~ Welcome to salon ~~\n"

show_services(){
    if [ $# -gt 0 ]; then
        echo -e "$1"
    fi
    SERVICES=$($PSQL "SELECT * FROM services")
    FORMATED_SERVICES=$(echo "$SERVICES" | sed 's/|/) /g')
    echo "$FORMATED_SERVICES"
}

echo "Please select service."
show_services

read SERVICE_ID_SELECTED

SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [ -z "$SERVICE_ID" ]; then
    #SERVICE_ID not found.
    show_services "\nPlease select existing service!"
else
    #SERVICE_ID found.
    echo -e "\nEnter phone number."

    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # CUSTOMER_ID not found
    if [ -z "$CUSTOMER_ID" ]; then

        # read customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # insert to customers table
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get CUSTOMER_ID again
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # read service time
    echo -e "\nSelect service time!"
    read SERVICE_TIME

    # insert to appointments table
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

    # appointment is successfully
    # select service name by SERVICE_ID
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")

    # select customer name by CUSTOMER_ID
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi