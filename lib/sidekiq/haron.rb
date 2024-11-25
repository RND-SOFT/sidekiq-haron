require 'sidekiq'
require 'sidekiq/haron/formatter'
require 'sidekiq/haron/redis_converts'
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
      @transmitter
    end

    def self.transmitter= v
      @transmitter = v
    end

    def self.install transmitter_class, with_tagged_logging: true
      Sidekiq::Haron.transmitter = transmitter_class.new
      set_loggers with_tagged_logging
      Sidekiq.configure_server do |c|
        configure_client_middleware(c)
        configure_server_middleware(c)
      end
      Sidekiq.configure_client do |c|
        configure_client_middleware(c)
      end
    end

    def self.set_loggers with_tagged_logging
      Sidekiq.configure_server do |config|
        config.logger.formatter = Sidekiq::Haron::Formatter.new
        config.logger = ActiveSupport::TaggedLogging.new(Sidekiq.logger) if with_tagged_logging

        config[:job_logger] = Sidekiq::Haron::JobLogger
        config.error_handlers << Sidekiq::Haron::ExceptionLogger.new
      end
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
