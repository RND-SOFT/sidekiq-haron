require 'sidekiq'
require 'sidekiq/haron/formatter'
require 'sidekiq/haron/storage'
require 'sidekiq/haron/transmitter'
require 'sidekiq/haron/job_logger'
require 'sidekiq/haron/exception_logger'
require 'sidekiq/haron/client_middleware'
require 'sidekiq/haron/server_middleware'
require 'sidekiq/haron/version'

module Sidekiq
  module Haron

    def self.transmitter
      Sidekiq.options[:transmitter]
    end

    def self.transmitter= v
      Sidekiq.options[:transmitter] = v
    end

    def self.install transmitter_class
      Sidekiq::Haron.transmitter = transmitter_class.new
      set_loggers
      Sidekiq.configure_server do |c|
        configure_client_middleware(c)
        configure_server_middleware(c)
      end
      Sidekiq.configure_client do |c|
        configure_client_middleware(c)
      end
    end

    def self.set_loggers
      Sidekiq.options[:job_logger] = Sidekiq::Haron::JobLogger
      Sidekiq.logger.formatter = Sidekiq::Haron::Formatter.new
      Sidekiq.logger = ActiveSupport::TaggedLogging.new(Sidekiq.logger)
      Sidekiq::Haron::ExceptionLogger.install
    end

    def self.configure_client_middleware(sidekiq_config)
      sidekiq_config.client_middleware do |chain|
        chain.add Sidekiq::Haron::ClientMiddleware
      end
    end

    def self.configure_server_middleware(sidekiq_config)
      sidekiq_config.server_middleware do |chain|
        if Sidekiq.major_version < 5
          chain.insert_after Sidekiq::Middleware::Server::Logging,
            Sidekiq::Haron::ServerMiddleware
        else
          chain.add Sidekiq::Haron::ServerMiddleware
        end
      end
    end

  end
end
