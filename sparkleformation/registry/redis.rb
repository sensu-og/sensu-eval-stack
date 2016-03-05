SfnRegistry.register(:redis) do
  metadata('AWS::CloudFormation::Init') do
    _camel_keys_set(:auto_disable)
    configSets do |sets|
      sets.default += ['sensu_redis']
    end
    sensu_redis do
      packages do
        apt do
          set!('redis-server', [ ])
        end
      end
      services do
        sysvinit do
          set!('redis-server') do
            enabled true
            ensureRunning true
            packages do
              apt [ 'redis-server' ]
            end
          end
        end
      end
    end
  end
end
