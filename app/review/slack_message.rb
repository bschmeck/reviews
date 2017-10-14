require 'active_support/cache'

module Review
  class SlackMessage
    @@cache = ActiveSupport::Cache::MemoryStore.new

    MessageClosed = Class.new(RuntimeError)

    def self.<<(message)
      new(message)
    end

    class << self
      def <<(message)
        new(message)
      end
    end

    attr_reader :message

    def initialize(message)
      @message = message
      @closed = false
    end

    def <<(appended)
      raise(MessageClosed, 'Message closed. Unable to modify.') if closed?

      @message = "#{message} #{appended}"

      self
    end

    def &(final = '')
      self << final

      close!

      @@cache.fetch(digest) { post }
    end

    def post
      # send to slack
      'k'
    end

    def close!
      @closed = true
    end

    def closed?
      @closed == true
    end

    private

    def digest
      Digest::SHA256.hexdigest message
    end
  end
end