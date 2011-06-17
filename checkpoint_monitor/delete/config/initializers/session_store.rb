# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_delete_session',
  :secret      => 'd637463093555e35fda17148eece6f645513cdc3881dbc84e98f6f96aaa8c0a78cd8a355116bdea4cc599c5689dbb05d98886f25b91d650b2c80199e56f57d91'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
