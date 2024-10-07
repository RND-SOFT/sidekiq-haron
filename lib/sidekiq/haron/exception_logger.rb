module Sidekiq
  module Haron
    class ExceptionLogger < Sidekiq::Logger

      def self.install
        Sidekiq.error_handlers.delete_if{|eh| eh.is_a? Sidekiq::Logger }
        Sidekiq.error_handlers.unshift Sidekiq::Haron::ExceptionLogger.new
      end

      def call(ex, ctxHash)
        jid = ctxHash.present? && ctxHash[:job]['jid']
        Sidekiq::Haron.transmitter.load(jid) if jid.present?
        Sidekiq::Haron.transmitter.tagged{ super(ex, ctxHash) }
      end

    end
  end
end