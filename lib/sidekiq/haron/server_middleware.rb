class Sidekiq::Haron::ServerMiddleware

  def call(worker, msg, queue)
    Sidekiq::Haron.transmitter.load(msg['jid'])
    yield
  end

end
