SparkleFormation.component(:compute) do

  ## Creates IAM user that can access compute resource metadata.
  resources do
    cfn_role do
      type 'AWS::IAM::Role'
      properties do
        assume_role_policy_document do
          version '2012-10-17'
          statement array!(
            -> {
              effect 'Allow'
              principal do
                service ['ec2.amazonaws.com']
              end
              action ['sts:AssumeRole']
            }
          )
        end
        path '/'
        policies array!(
          -> {
            policy_name 'cfn_access'
            policy_document do
              statement array!(
                -> {
                  effect 'Allow'
                  action 'cloudformation:DescribeStackResource'
                  resource '*'
                }
              )
            end                 
          }
        )
      end
    end
  end
end

