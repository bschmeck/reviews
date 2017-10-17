# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:aliases) do
      primary_key %i[username aliasname]

      String :username
      String :aliasname
    end
  end
end
