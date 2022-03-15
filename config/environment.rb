require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require 'yaml'
require_relative '../lib/featviz'
require_relative '../apps/web/application'

config_path = File.expand_path(File.dirname(__FILE__)) + "/config.yml"
config_hash = YAML.load_file(config_path)
configatron.configure_from_hash(config_hash)

Hanami.configure do
  mount Web::Application, at: '/'

  model do
    ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/featviz_development.sqlite3'
    #    adapter :sql, 'postgresql://localhost/featviz_development'
    #    adapter :sql, 'mysql://localhost/featviz_development'
    #
    adapter :sql, ENV.fetch('DATABASE_URL')

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/featviz/mailers'

    # See https://guides.hanamirb.org/mailers/delivery
    delivery :test
  end

  environment :development do
    # See: https://guides.hanamirb.org/projects/logging
    logger level: :debug
  end

  environment :production do
    logger level: :info, formatter: :json, filter: []

    mailer do
      delivery :smtp, address: ENV.fetch('SMTP_HOST'), port: ENV.fetch('SMTP_PORT')
    end
  end
end
