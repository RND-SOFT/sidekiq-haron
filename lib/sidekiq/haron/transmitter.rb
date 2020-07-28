module Sidekiq
  module Haron
    class Transmitter
      include Sidekiq::Haron::Storage

      def save worker_class, msg, queue, redis_pool
        data = saved_data(worker_class, msg, queue)
        store_for_id msg['jid'], data, redis_pool
      end

      def load jid
        load_data read_for_id(jid)
      rescue => e
        Sidekiq.logger.error "loading data error #{jid} - #{e.to_s}"
        {}
      end

      def clean jid
        clean_for_id(jid)
      rescue => e
        Sidekiq.logger.error "clean error #{jid} - #{e.to_s}"
        nil
      end

      def tagged
        ::Rails.logger.tagged(tags) do 
          Sidekiq.logger.tagged(tags) do 
            yield
          end
        end

      end

      def tags
        []
      end

      private

      def saved_data
        raise NotImplemented
      end

      def load_data
        raise NotImplemented
      end

    end
  end
end
