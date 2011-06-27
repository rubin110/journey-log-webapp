# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SurvivedcOrg::Application.initialize!

SurvivedcOrg::Application.configure do
  config.action_controller.relative_url_root = '/20110618-sf/cpm'
end

