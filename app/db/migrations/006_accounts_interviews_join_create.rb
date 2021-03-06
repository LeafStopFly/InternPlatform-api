# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(owned_id: :accounts, interviews_id: { table: :interviews, type: :uuid })
  end
end
