source common.sh

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> install nginx service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
yum install nginx -y &>>${log}
func_exit_status

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> copy roboshop configuration <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
cp nginx.conf /etc/nginx/default.d/roboshop.conf &>>${log}
func_exit_status

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> clean old content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
rm -rf /usr/share/nginx/html/* &>>${log}
func_exit_status

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> downloading application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log}
func_exit_status

cd /usr/share/nginx/html &>>${log}

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> extracting application content <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
unzip /tmp/frontend.zip &>>${log}
func_exit_status

echo -e "\e[36m>>>>>>>>>>>>>>>>>>>>>>>> start nginx service <<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
systemctl enable nginx &>>${log}
systemctl restart nginx &>>${log}
func_exit_status


