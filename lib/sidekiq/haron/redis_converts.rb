module Sidekiq
  module Haron
    module Storage
      module RedisConverts
        # Введена интерпретация значений nil, true, false в связи с возникающими ошибками:
        #   nil   - 'NilClass'
        #   true  - 'TrueClass'
        #   false - 'FalseClass'

        CLASSES_TO_CONVERT  = { NilClass  => {redis_value: 'NilClass',    orig_value: nil},
                              TrueClass   => {redis_value: 'TrueClass',   orig_value: true},
                              FalseClass  => {redis_value: 'FalseClass',  orig_value: false} }.freeze

        def encode_values_from array
          return array unless array.is_a?(Array)

          array.map do |value|
            CLASSES_TO_CONVERT.keys.include?(value.class) ? CLASSES_TO_CONVERT[value.class][:redis_value] : value
          end
        end

        def decode_values_from hash
          return hash unless hash.is_a?(Hash)

          hash.transform_values do |value|
            key = key_by_redis_value(value)
            value = key.nil? ? value : CLASSES_TO_CONVERT[key][:orig_value]
          end
        end

        private

        def key_by_redis_value redis_value
          CLASSES_TO_CONVERT.each do |k, v|
            return k if v[:redis_value] == redis_value
          end
        end

      end
    end
  end
end
