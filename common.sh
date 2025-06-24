#!/bin/bash

    START_TIME=$(date +%s)
    USERID="$(id -u)"   # CHECK USER ID 
    R="\e[31m"          
    G="\e[32m"          #BY ADDING COLORS FOR ERRORS SUCCSES
    Y="\e[33m"
    N="\e[0m"

    LOG_FOLDER="/var/log/roboshop.log"
    SCRIPT_NAME="$(echo $0 | cut -d "." f1)"
    LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
    SCRIPT_DIR=$PWD

    mkdir -p $LOG_FOLDER 
    echo -e "$Y This  script started excuting at :: $(date) $N" | tee -a $LOG_FILE  # THIS COMMAND REFER DISPLY THE CONTEND AND STORE IN LOG_FILE

    

    app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping $app_name"
}

    nodejs_setup(){ 
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
    }
    
    maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and Java"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"
    }

    systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name  &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting $app_name"

    }

   check_root(){
        if [ $USERID -ne 0 ]    # CHECK USER ID IF USER ID 0 ITS ROOT USER OTHER WISE NOT ROOT
        then
            echo -e "$R ERROR  ::  plese run this script root acces $N" | tee -a $LOG_FILE
            exit 1  # 1 REFER EXIT THE SCRIPT OR STOP
        else
            echo -e "$G this script running with root access nothing to do $N" | tee -a $LOG_FILE
        fi 
    }
    VALIDATE(){
        if [ $1 -eq 0 ]
        then 
            echo -e "$2 ... IS $G SUCCSESS $N"
        else
            echo -e "$2.....is $R FAILURE $N "
            exit 1
            
        fi
    }



  print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
  }