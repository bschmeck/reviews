# frozen_string_literal: true

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

      self.class.new "#{message} #{appended}"
    end

    def +(other)
      self << other.message
    end

    def &(final = '')
      finalizer = final.present? ? self << final : self

      result = finalizer.post

      finalizer.close!

      close!

      result
    end

    def post
      @@cache.fetch checksum do
        { message: 'Slack message sent',
          contents: message,
          sent_at:  timestamp,
          checksum: checksum }
      end
    end

    def close!
      @closed = true
    end

    def closed?
      @closed == true
    end

    private

    def timestamp
      Time.now.utc
    end

    def checksum
      Digest::SHA256.hexdigest message
    end
  end
end
