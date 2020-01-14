module Sidekiq
  module Haron
    module Storage

      DEFAULT_EXPIRY = 30 * 24 * 60 * 60 # 30 days

      protected

      def store_for_id(id, data, redis_pool=nil)
        redis_connection(redis_pool) do |conn|
          conn.multi do
            conn.hmset  key(id), *(data.to_a.flatten(1))
            conn.expire key(id), DEFAULT_EXPIRY
          end[0]
        end
      end

      def read_for_id(id)
        Sidekiq.redis do |conn|
          conn.hgetall(key(id))
        end
      end

      private

      def redis_connection(redis_pool=nil)
        if redis_pool
          redis_pool.with do |conn|
            yield conn
          end
        else
          Sidekiq.redis do |conn|
            yield conn
          end
        end
      end

      def key(id)
        "sidekiq:haron:#{id}"
      end
    end
  end
end
