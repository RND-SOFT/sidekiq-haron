module Sidekiq
  module Haron
    module Storage
      module RedisConverts
        # Введена интерпретация значений nil, true, false в связи с возникающими ошибками:
        #   nil   - 'NilClass'
        #   true  - 'TrueClass'
        #   false - 'FalseClass'

        CLASSES_TO_CONVERT      = [NilClass, TrueClass, FalseClass].freeze
        CLASSES_TO_CONVERT_STR  = CLASSES_TO_CONVERT.map{ |v| v.to_s }.freeze

        def encode_values_from array
          return array unless array.is_a?(Array)

          array.map do |value|
            CLASSES_TO_CONVERT.include?(value.class) ? value.class.to_s : value
          end
        end

        def decode_values_from hash
          return hash unless hash.is_a?(Hash)

          hash.transform_values do |value|
            if CLASSES_TO_CONVERT_STR.include? value
              if value.downcase.include? 'true'
                value = true
              elsif value.downcase.include? 'false'
                value = false
              else
                value = nil
              end
            else
              value
            end
          end
        end
      end
    end
  end
end
