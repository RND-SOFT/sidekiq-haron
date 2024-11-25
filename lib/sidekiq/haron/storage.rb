module Sidekiq
  module Haron
    module Storage

      include RedisConverts

      DEFAULT_EXPIRY = 7 * 24 * 60 * 60 # 7 days

      protected

      def store_for_id(id, data, redis_pool=nil)
        redis_connection(redis_pool) do |conn|
          conn.multi do |pipeline|
            # При попытке записи хэша с полями nil, true, false
            # валится задание с исключением "Unsupported command argument type: NilClass/TrueClass/FalseClass (TypeError)"
            # Пример из консоли Rails (такое же поведение в "бою", данные взяты из реальных кейсов)
            # d = [ :request_id, "9c30943e299135b1fe826d7be6195e78", :parent_request_id, "9c30943e",:user_id, nil ]
            # Sidekiq.redis { |c| c.call('hmset', "kkk", d) }
            # ~/.rvm/gems/ruby-3.3.5/gems/irb-1.14.1/lib/irb.rb:1260:in `full_message': Unsupported command argument type: NilClass (TypeError)
            # raise TypeError, "Unsupported command argument type: #{element.class}"
            #       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            # уход от deprecated-предупреждений внутри sidekiq - нативный вызов hmset для клиента redis
            pipeline.call('hmset', key(id), *(encode_values_from data.to_a.flatten(1)))
            pipeline.expire key(id), DEFAULT_EXPIRY
          end[0]
        end
      end

      def read_for_id(id)
        Sidekiq.redis do |conn|
          decode_values_from conn.hgetall(key(id))
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
