SfnRegistry.register(:sensu_client) do | _config = {} |
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    configSets do |sets|
      sets.default += ['sensu_client_configs']
    end

    sensu_client_configs do
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
