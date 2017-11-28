# frozen_string_literal: true

module Review
  class SlackUsernameFormatter
    def self.call(username)
      return username unless silence?
      silent(username)
    end

    def self.silent(username)
      return 'anybody' if username.empty?

      index = if username.length < 3
                -2
              else
                -3
              end
      username.dup.insert(index, '.')
    end

    def self.silence?
      too_early? || too_late?
    end

    def self.too_late?
      current_time_in_seconds > silence_start
    end

    def self.too_early?
      current_time_in_seconds < silence_finish
    end

    def self.current_time_in_seconds
      Time.zone = zone
      Time.zone.now.seconds_since_midnight
    end

    def self.zone
      settings.dig('silence', 'zone')
    end

    def self.silence_start
      settings.dig('silence', 'start')
    end

    def self.silence_finish
      settings.dig('silence', 'end')
    end

    def self.settings
      @settings ||= YAML.load_file(
        ENV.fetch('CONFIG_FILE', 'config/settings.yml.example')
      )
    end
  end
end
