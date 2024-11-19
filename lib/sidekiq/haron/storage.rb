module Sidekiq
  module Haron
    module Storage

      DEFAULT_EXPIRY = 7 * 24 * 60 * 60 # 7 days

      protected

      def store_for_id(id, data, redis_pool=nil)
        redis_connection(redis_pool) do |conn|
          conn.multi do |pipeline|
            values = data.to_a.flatten(1).map{ |each| each.nil? ? '' : each }.map{ |each| each == true ? 1 : (each == false ? 0 : each) }

            pipeline.hset  key(id), *values
            pipeline.expire key(id), DEFAULT_EXPIRY
          end[0]
        end
      end

      def read_for_id(id)
        Sidekiq.redis do |conn|
          conn.hgetall(key(id))
        end
      end

      def clean_for_id(id)
        Sidekiq.redis do |conn|
          conn.del(key(id))
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
