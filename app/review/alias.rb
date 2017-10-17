# frozen_string_literal: true

require 'sequel'

module Review
  class Alias
    DB = Sequel.connect 'sqlite://db/alias.db'

    class << self
      def for(username)
        DB[:aliases].select(:aliasname).where(username: username).first
      end

      def make(username, aliasname)
        DB[:aliases]
          .insert_conflict
          .multi_insert([
                          { username: username, aliasname: aliasname },
                          { username: aliasname, aliasname: username }
                        ])
      end
    end
  end
end
