module Sidekiq
  module Haron
    class ExceptionLogger

      def call(ex, ctxHash)
        jid = ctxHash.present? && ctxHash[:job]['jid']
        Sidekiq::Haron.transmitter.load(jid) if jid.present?
        Sidekiq::Haron.transmitter.tagged{ super(ex, ctxHash) }
      end

    end
  end
end