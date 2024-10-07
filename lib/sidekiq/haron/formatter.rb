module Sidekiq
  module Haron
    class Formatter < Sidekiq::Logger::Formatters::Pretty

      def call(severity, time, program_name, message)
        result = "#{context} #{severity.to_s[0]}: #{message}\n"
        if ENV['RAILS_LOG_TO_STDOUT'].present?
          result
        else
          "#{time.utc.iso8601(3)} #{result}"
        end
      end

    end
  end
end
