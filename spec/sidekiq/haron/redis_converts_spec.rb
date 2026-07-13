RSpec.describe Sidekiq::Haron::Storage::RedisConverts do
  subject(:converter) do
    Class.new do
      include Sidekiq::Haron::Storage::RedisConverts
    end.new
  end

  describe '#encode_values_from' do
    it 'encodes nil and boolean values' do
      data = ['request-id', nil, true, false]

      expect(converter.encode_values_from(data)).to eq(%w[request-id NilClass TrueClass FalseClass])
    end
  end

  describe '#decode_values_from' do
    it 'decodes encoded values and keeps regular strings unchanged' do
      data = {
        'request_id' => 'request-id',
        'user_id' => 'NilClass',
        'enabled' => 'TrueClass',
        'archived' => 'FalseClass'
      }

      expect(converter.decode_values_from(data)).to eq(
                                                      'request_id' => 'request-id',
                                                      'user_id' => nil,
                                                      'enabled' => true,
                                                      'archived' => false
                                                    )
    end
  end
end
