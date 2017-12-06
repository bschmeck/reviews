# frozen_string_literal: true

module Review
  class SlackUsername
    attr_reader :username

    def initialize(username)
      @username = username
    end

    def to_s
      return dotted if silence?

      username
    end

    def ==(other)
      username == other.username
    end

    private

    def dotted
      @dotted ||= begin
                  index = if username.length < 3
                            -2
                          else
                            -3
                          end
                  username.dup.insert(index, '.')
                end
    end

    def silence?
      too_early? || too_late?
    end

    def too_late?
      current_time_in_seconds > silence_start
    end

    def too_early?
      current_time_in_seconds < silence_finish
    end

    def current_time_in_seconds
      Time.zone = zone
      Time.zone.now.seconds_since_midnight
    end

    def zone
      settings.dig('silence', 'zone')
    end

    def silence_start
      settings.dig('silence', 'start')
    end

    def silence_finish
      settings.dig('silence', 'end')
    end

    def settings
      @settings ||= YAML.load_file(
        ENV.fetch('CONFIG_FILE', 'config/settings.yml.example')
      )
    end
  end
end
