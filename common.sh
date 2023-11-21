log=/tmp/roboshop.log

func_exit_status() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}

func_apppreq() {
  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create ${component} service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create application user <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  id roboshop &>>${log}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${log}
  fi
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> removing old application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  rm -rf /app&>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create application directory <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  mkdir /app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> download application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> extract application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
  func_exit_status
}
func_systemd() {
  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> start ${component} service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
  func_exit_status
}

func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install mongo client <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
    yum install mongodb-org-shell -y &>>${log}
    func_exit_status

    echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> load user schema <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
    mongo --host mongodb.entertanova.com </app/schema/${component}.js &>>${log}
  fi

  if [ "${schema_type}" == "mysql" ]; then
    echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install mysql service client <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
    yum install mysql -y &>>${log}
    func_exit_status

    echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> load schema <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
    mysql -h mysql.entertanova.com -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
    func_exit_status
  fi
}

func_nodejs() {
  log=/tmp/roboshop.log

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create mongodb repo <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install nodejs repos <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install nodejs <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  yum install nodejs -y &>>${log}
  func_exit_status

  func_apppreq
  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> download nodejs dependencies <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  npm install &>>${log}
  func_exit_status

  func_schema_setup

  func_systemd
}

func_java() {
  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install maven <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  yum install maven -y &>>${log}
  func_exit_status

  func_apppreq

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> build ${component} service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}
  func_exit_status

  func_schema_setup

  func_systemd
}

func_python() {
  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> build ${component} service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}
  func_exit_status

  func_apppreq

  sed -i "s/rabbitmq_app_password/${rabbitmq_app_password}" /etc/systemd/system/${component}.service

  echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> build ${component} service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>>${log}
  func_exit_status

  func_systemd
}
