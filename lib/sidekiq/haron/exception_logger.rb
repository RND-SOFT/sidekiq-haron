module Sidekiq
  module Haron
    class ExceptionLogger

      def call(ex, ctx_hash, config)
        jid = ctx_hash.present? && ctx_hash[:job]['jid']

        Sidekiq::Haron.transmitter.load(jid) if jid.present?
        Sidekiq::Haron.transmitter.tagged{ Sidekiq.logger.warn ex.message }
      end

    end
  end
end