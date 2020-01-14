class Sidekiq::Haron::ClientMiddleware

  def call(worker_class, msg, queue, redis_pool=nil)
    if msg['retry_count'].blank? # don't store on retry
      Sidekiq::Haron.transmitter.save(worker_class, msg, queue, redis_pool)
    end
    yield
  end

end
