desc "Setup cf for running specs"
task :setup do
  sh "cf api api.bosh-lite.com --skip-ssl-validation"
  sh "cf auth admin admin"
  sh "cf create-org services"
  sh "cf create-space contrib -o services"
  sh "cf target -o services -s contrib"

  %w(mongodb postgresql redis rabbitmq).each do |service|
    create_service_auth_token(service, "c1oudc0w")
  end
end

def create_service_auth_token(name, token)
  sh "cf delete-service-auth-token #{name} core -f"
  sh "cf create-service-auth-token #{name} core #{token}"
end
