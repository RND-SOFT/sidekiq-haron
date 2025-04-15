module MonkeyPatching
  module ActiveSupport
    module  BroadcastLoggerPatcher
      private

      def method_missing(name, ...)
        loggers = if name == :tagged
                    # only this way reimplemented
                    @broadcasts.select { |logger| !logger.is_a?(::Sidekiq::Logger) && logger.respond_to?(:tagged) }
                  else
                    @broadcasts.select { |logger| logger.respond_to?(name) }
                  end

        if loggers.none?
          super
        elsif loggers.one?
          loggers.first.send(name, ...)
        else
          loggers.map { |logger| logger.send(name, ...) }
        end
      end
    end
  end
end

ActiveSupport::BroadcastLogger.prepend MonkeyPatching::ActiveSupport::BroadcastLoggerPatcher
