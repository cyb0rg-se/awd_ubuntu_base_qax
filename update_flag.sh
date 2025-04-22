#!/bin/bash

# Define the log file path
LOG_FILE="/var/log/update_flag.log"

# Ensure the log file exists
touch "$LOG_FILE"

# Function to check if the script is already running
check_running() {
    pidof -o %PPID -x "$0" > /dev/null
    if [ $? -eq 0 ]; then
        echo "$(date): Script is already running. Exiting." >> "$LOG_FILE"
        exit 1
    fi
}

# Function to check and start MySQL service
check_mysql() {
    if ! service mysql status > /dev/null 2>&1; then
        echo "$(date): MySQL service is not running. Attempting to start..." >> "$LOG_FILE"
        service mysql start
        if service mysql status > /dev/null 2>&1; then
            echo "$(date): MySQL service started successfully." >> "$LOG_FILE"
        else
            echo "$(date): Failed to start MySQL service." >> "$LOG_FILE"
        fi
    fi
}

# Function to check and start Apache2 service
check_apache2() {
    if ! service apache2 status > /dev/null 2>&1; then
        echo "$(date): Apache2 service is not running. Attempting to start..." >> "$LOG_FILE"
        service apache2 start
        if service apache2 status > /dev/null 2>&1; then
            echo "$(date): Apache2 service started successfully." >> "$LOG_FILE"
        else
            echo "$(date): Failed to start Apache2 service." >> "$LOG_FILE"
        fi
    fi
}

# Function to check and start SSH service
check_ssh() {
    if ! service ssh status > /dev/null 2>&1; then
        echo "$(date): SSH service is not running. Attempting to start..." >> "$LOG_FILE"
        service ssh start
        if service ssh status > /dev/null 2>&1; then
            echo "$(date): SSH service started successfully." >> "$LOG_FILE"
        else
            echo "$(date): Failed to start SSH service." >> "$LOG_FILE"
        fi
    fi
}

# Check if the script is already running
check_running

# Check MySQL and Apache2 services
check_mysql
check_apache2
check_ssh

# Execute every 5 seconds
while true; do
    # Use curl to fetch content
    QAXFLAG=$(curl -k https://${IP}/Getkey/index/index 2>/dev/null)

    # Check if the curl command was successful
    if [ $? -eq 0 ]; then
        # If successful, write the result to the environment variable and file
        export QAXFLAG
        echo "$QAXFLAG" > /flag
        echo "$(date): Successfully fetched data and updated /flag" >> "$LOG_FILE"
    else
        # If failed, write 'no' to the environment variable and file
        QAXFLAG="no"
        export QAXFLAG
        echo "$QAXFLAG" > /flag
        echo "$(date): Failed to fetch data from URL, set QAXFLAG to 'no'" >> "$LOG_FILE"
    fi

    # Set permissions and ownership for /flag
    chown root:root /flag  # Set owner to root
    chmod 644 /flag        # Set permissions to read/write for owner, read for others

    # Wait for 5 seconds
    sleep 5
done
