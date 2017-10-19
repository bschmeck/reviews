# frozen_string_literal: true

RSpec.describe Review::Cache do
  describe '.current' do
    context 'with an in-memory fallback' do
      before do
        ENV.delete('REDIS_URL')
        Review::Cache.instance_variable_set(:@cache, nil)
      end

      it 'uses an active support memory cache' do
        expect(described_class.current).to be_a(ActiveSupport::Cache::MemoryStore)
      end
    end

    context 'with a redis endpoint defined' do
      before do
        ENV['REDIS_URL'] = 'redis://localhost:6379/2'
        Review::Cache.instance_variable_set(:@cache, nil)
      end

      after do
        ENV.delete('REDIS_URL')
        Review::Cache.instance_variable_set(:@cache, nil)
      end

      it 'uses a redis backed cache' do
        expect(described_class.current.options).to include(
          redis: { url: 'redis://localhost:6379/2' }
        )
      end
    end
  end
end
