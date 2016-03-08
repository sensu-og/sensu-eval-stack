SfnRegistry.register(:sensu_client) do | _config = {} |
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    configSets do |sets|
      sets.default += ['sensu_core_repos', 'sensu_client_install', 'sensu_client_start', 'sensu_config_examples']
    end

    sensu_core_repos do
      commands('01_sensu_core_gpg') do
        command 'wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -'
      end
      commands('02_sensu_core_repos') do
        command 'echo "deb     http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list'
      end
      commands('03_apt_get_update') do
        command 'sudo apt-get update'
      end
    end

    sensu_client_install do
      files('/etc/sensu/conf.d/client.json') do
        content do
          client do
            name 'sensu_eval'
            address 'localhost'
            subscriptions [ 'all' ]
          end
          rabbitmq do
            host 'localhost'
            vhost '/sensu'
            user 'sensu'
            password _config.fetch(:queue_password, 'secret')
          end
        end
        owner 'sensu'
        group 'sensu'
        mode '000660'
      end

      packages do
        apt do
          sensu [ ]
        end
      end
    end

    sensu_client_start do
      commands('start_sensu_client') do
        command 'sudo service sensu-client start'
      end
    end

    sensu_config_examples do
      files('/home/ubuntu/remote_client_example.json') do
        content do
          client do
            name 'remote_client'
            address 'remote_client_address'
            subscriptions [ 'all' ]
          end
          rabbitmq do
            host 'PublicRabbitMqHost (from Stack Outputs)'
            vhost '/sensu'
            user 'sensu'
            password _config.fetch(:queue_password, 'secret')
          end
        end
        owner 'ubuntu'
        mode '000600'
      end
      files('/home/ubuntu/vpc_client_example.json') do
        content do
          client do
            name 'vpc_client'
            address 'vpc_client_address'
            subscriptions [ 'all' ]
          end
          rabbitmq do
            host 'PrivateRabbitMqHost (from Stack Outputs)'
            vhost '/sensu'
            user 'sensu'
            password _config.fetch(:queue_password, 'secret')
          end
        end
        owner 'ubuntu'
        mode '000600'
      end
    end
  end
end
