echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create catalogue service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create mongodb repo <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install nodejs repos <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install nodejs <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
yum install nodejs -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create application user <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
useradd roboshop &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> removing old content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
rm -rf /app&>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> create application directory <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
mkdir /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> download application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> extract application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>/tmp/roboshop.log
cd /app

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> download nodejs dependencies <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
npm install &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install mongo client <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> load catalogue schema <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
mongo --host mongodb.entertanova.com </app/schema/catalogue.js &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> start catalogue service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
systemctl daemon-reload &>>/tmp/roboshop.log
systemctl enable catalogue &>>/tmp/roboshop.log
systemctl restart catalogue &>>/tmp/roboshop.log

