module Sidekiq
  module Haron
    class ServerMiddleware

      def call(worker, msg, queue)
        Sidekiq::Haron.transmitter.load(msg['jid'])
        yield
        # job successfully end
        Sidekiq::Haron.transmitter.clean(msg['jid'])
      end

    end
  end
end
