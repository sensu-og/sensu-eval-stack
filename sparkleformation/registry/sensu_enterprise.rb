SfnRegistry.register(:sensu_enterprise) do | _config = {} |
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    configSets do |sets|
      sets.default += ['sensu_enterprise_repos',
        'sensu_enterprise_install',
        'sensu_enterprise_config',
        'sensu_enterprise_start']
    end

    sensu_enterprise_repos do
      commands('01_sensu_enterprise_gpg') do
        command join!('wget -q http://',
          ref!(:sensu_repo_user), ':',
          ref!(:sensu_repo_pass),
          '@enterprise.sensuapp.com/apt/pubkey.gpg -O- | sudo apt-key add -')
      end
      commands('02_sensu_enterprise_repos') do
        command join!('echo "deb     http://',
          ref!(:sensu_repo_user), ':',
          ref!(:sensu_repo_pass),
          '@enterprise.sensuapp.com/apt sensu-enterprise main" | sudo tee /etc/apt/sources.list.d/sensu-enterprise.list')
      end
      commands('03_apt_get_update') do
        command 'sudo apt-get update'
      end
    end

    sensu_enterprise_install do
      packages do
        apt do
          set!('sensu-enterprise', [ ])
          set!('sensu-enterprise-dashboard', [ ])
        end
      end
      services do
        sysvinit do
          enabled true
          ensureRunning true
          packages do
            apt ['sensu-enterprise', 'sensu-enterprise-dashboard']
          end
          files ['/etc/sensu/config.json', '/etc/sensu/dashboard.json']
        end
      end
    end

    sensu_enterprise_config do
      commands('create_config_dir') do
        command 'sudo mkdir -p /etc/sensu'
      end
      files('/etc/sensu/config.json') do
        content do
          rabbitmq do
            host 'localhost'
            vhost '/sensu'
            user 'sensu'
            password _config.fetch(:queue_password, 'secret')
          end
          redis do
            host 'localhost'
          end
          api do
            host 'locahost'
          end
        end
      end
      files('/etc/sensu/dashboard.json') do
        content do
          sensu array!(
            -> {
              name 'Datacenter 1'
              host 'localhost'
            }
          )
          dashboard do
            host '0.0.0.0'
          end
        end
      end
    end

    sensu_enterprise_start do
      commands('01_start_sensu_enterprise') do
        command 'sudo service sensu-enterprise start'
      end
      commands('02_start_sensu_enterprise_dashboard') do
        command 'sudo service sensu-enterprise-dashboard start'
      end
    end
  end
end
