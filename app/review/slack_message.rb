# frozen_string_literal: true

require 'httparty'

module Review
  class SlackMessage
    MessageClosed = Class.new(RuntimeError)

    class << self
      def <<(message)
        new(message)
      end
    end

    attr_reader :message, :cache

    def initialize(message, cache: Review::Cache.current)
      @message = format message
      @closed = false
      @cache  = cache
    end

    def <<(appended)
      raise(MessageClosed, 'Message closed. Unable to modify.') if closed?

      self.class.new "#{message} #{format appended}"
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
      cache.fetch checksum do
        post_to_slack! message

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

    def format(message)
      if message.respond_to? :slack_username
        SlackUsernameFormatter.call(message.slack_username)
      else
        message.to_s
      end
    end

    def post_to_slack!(message)
      HTTParty.post(ENV['SLACK_WEBHOOK'], body: { text: message }.to_json)
    end

    def timestamp
      Time.now.utc
    end

    def checksum
      Digest::SHA256.hexdigest message
    end
  end
end
