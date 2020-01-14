require 'sidekiq/job_logger'
class Sidekiq::Haron::JobLogger < Sidekiq::JobLogger

  def call(item, queue)
    Sidekiq::Haron.transmitter.load(item['jid'])
    Sidekiq::Haron.transmitter.tagged do 
      Sidekiq.logger.info("with args #{item['args'].inspect}")
      super
    end
  end
  
end
