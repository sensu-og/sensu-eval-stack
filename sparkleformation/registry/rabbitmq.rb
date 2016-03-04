SfnRegistry.register(:rabbitmq) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    configSets do |sets|
      sets.default += ['sensu_rabbitmq']
    end
    sensu_rabbitmq do
      commands('01_erlang_package') do
        command 'sudo wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb'
      end
      commands('02_apt_get_update') do
        command 'sudo apt-get update && sudo apt-get -f install'
      end
      commands('03_install_erlang') do
        command 'sudo apt-get -y install erlang-nox=1:18.2'
      end
      commands('04_rabbitmq_package') do
        command 'sudo wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.0/rabbitmq-server_3.6.0-1_all.deb && sudo dpkg -i rabbitmq-server_3.6.0-1_all.deb'
      end
      commands('05_configure_rabbit_mq') do
        command 'sudo rabbitmqctl add_vhost /sensu && sudo rabbitmqctl add_user sensu secret && sudo rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"'
      end
    end
  end
end
