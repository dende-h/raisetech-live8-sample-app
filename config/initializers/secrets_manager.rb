# config/initializers/secrets_manager.rb

require 'aws-sdk-secretsmanager'

client = Aws::SecretsManager::Client.new(region: 'your-region')

begin
  # database secretの取得
  db_secret = JSON.parse(client.get_secret_value(secret_id: 'MyDatabaseSecret').secret_string)
  Rails.application.config.db_username = db_secret['username']
  Rails.application.config.db_password = db_secret['password']

  # secret_key_baseの取得
  secret_key_base = client.get_secret_value(secret_id: 'MySecretKeyBase').secret_string
  Rails.application.config.secret_key_base = secret_key_base
rescue Aws::SecretsManager::Errors::ResourceNotFoundException => e
  Rails.logger.error("Secrets not found: #{e.message}")
rescue StandardError => e
  Rails.logger.error("Error initializing secrets: #{e.message}")
end
