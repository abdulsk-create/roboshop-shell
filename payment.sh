component=payment
source common.sh
if [ -z "${rabbitmq_app_password}" ]; then
  echo Input RabbitMQ AppUser Password Missing
  exit 1
fi
func_python
