#!/bin/bash

# Log file path
LOG_FILE="/root/update_flag.log"
IMPORT_MARKER="/root/db_import_done"
SQL_FILE="/var/www/html/db.sql"
touch "$LOG_FILE"

# Prevent multiple instances of this script
check_running() {
    pidof -o %PPID -x "$0" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Script is already running. Exiting." >> "$LOG_FILE"
        exit 1
    fi
}

# Check if a given port is listening; if not, restart the corresponding service
# $1 = port number; $2 = service name
check_service_port() {
    local port=$1
    local svc=$2

    if ! netstat -tln 2>/dev/null | grep -qE "[:\.]${port}[[:space:]]+.*LISTEN"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Port ${port} is not listening; restarting ${svc}..." >> "$LOG_FILE"
        service "$svc" restart

        # Verify after restart
        if netstat -tln 2>/dev/null | grep -qE "[:\.]${port}[[:space:]]+.*LISTEN"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S'): ${svc} restart succeeded; port ${port} is now listening." >> "$LOG_FILE"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Failed to restart ${svc}, port ${port} still not listening!" >> "$LOG_FILE"
        fi
    fi
}

# Import the SQL file exactly once, if MySQL is up and the marker file is absent
import_db_once() {
    if [ ! -f "$IMPORT_MARKER" ] && netstat -tln 2>/dev/null | grep -qE "[:\.]3306[[:space:]]+.*LISTEN"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): MySQL is up; importing $SQL_FILE..." >> "$LOG_FILE"
        mysql -h127.0.0.1 -uctf -p123456 < "$SQL_FILE"
        if [ $? -eq 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Database import succeeded." >> "$LOG_FILE"
            touch "$IMPORT_MARKER"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Database import FAILED!" >> "$LOG_FILE"
        fi
    fi
}

# Initial check to avoid parallel runs
check_running

# Main loop: every 5 seconds, check ports/services, import DB once, then fetch flag
while true; do
    # 1) Port/service health checks
    check_service_port 22   ssh
    check_service_port 80   apache2
    check_service_port 3306 mysql

    # 2) Import SQL into MySQL exactly once
    import_db_once

    # 3) Original curl-based flag fetch (interval remains 5s)
    QAXFLAG=$(curl -k https://${IP}/Getkey/index/index 2>/dev/null)
    if [ $? -eq 0 ]; then
        export QAXFLAG
        echo "$QAXFLAG" > /flag
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Successfully fetched flag and wrote to /flag" >> "$LOG_FILE"
    else
        QAXFLAG="no"
        export QAXFLAG
        echo "$QAXFLAG" > /flag
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Failed to fetch flag; set QAXFLAG='no' and wrote to /flag" >> "$LOG_FILE"
    fi

    # Ensure /flag has the correct ownership and permissions
    chown root:root /flag
    chmod 644 /flag

    # Wait 5 seconds before next iteration
    sleep 5
done
