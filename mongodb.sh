#!/bin/bash
    
    source ./common.sh
    app_name=mongodb
    
    check_root

    #CREATING MONGODB USING SHELL SCRIPT
    cp mongod.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
    VALIDATE $? "Copying MongoDB repo"

    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "Installing MongoDB Server"

    systemctl enable mongod &>>$LOG_FILE
    VALIDATE $? "Eanbleing MongoDB"

    systemctl start mongod &>>$LOG_FILE 
    VALIDATE $? "Starting MongoDB"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    VALIDATE $? "Editing MongoDB Repo file to Remote Conections"

    systemctl restart mongod &>>$LOG_FILE
    VALIDATE $? "Restartig MongoDB"

    print_time
        