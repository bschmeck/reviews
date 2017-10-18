# frozen_string_literal: true

ENV['USERNAME_ALIASES'] = 'config/aliases.yml.example'
ENV['CONFIG_FILE'] = 'config/settings.yml.example'

require './app/review'
