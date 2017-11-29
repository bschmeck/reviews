# frozen_string_literal: true

module Review
  class Alias
    class << self
      def for(username)
        aliasname = aliases.fetch(username, username)

        if silence?
          silent aliasname
        else
          aliasname
        end
      end

      def silent(aliasname)
        case aliasname.length
        when 0
          'anybody'
        when 1
          ".#{aliasname}"
        when 2
          "#{aliasname[0]}.#{aliasname[1]}"
        else
          "#{aliasname[0..-3]}.#{aliasname[-2..-1]}"
        end
      end

      def silence?
        too_early? || too_late?
      end

      private

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

      def aliases
        return @aliases if defined? @aliases

        names = YAML.load_file(
          ENV.fetch('USERNAME_ALIASES', 'config/aliases.yml.example')
        )

        @aliases = names.merge(names.invert)
      end
    end
  end
end
