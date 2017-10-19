# frozen_string_literal: true

require 'active_support/cache'
require 'hiredis'
require 'readthis'

module Review
  class Cache
    class << self
      def current
        @cache ||= cache
      end

      private

      def cache
        Readthis::Cache.new(
          expires_in: 1.day.to_i,
          redis: { url: ENV.fetch('REDIS_URL') }
        )
      rescue KeyError
        ActiveSupport::Cache::MemoryStore.new
      end
    end
  end
end
