require 'csv'

# @note This is used to import Amex CSV Statements
# Export the statement CSV from within the web app

module F2ynab
  module Import
    module Csv
      class Amex
        def initialize(path, ynab_account_id)
          @path = path
          @ynab_account_id = ynab_account_id
          @import_id_creator = ::F2ynab::YNAB::ImportIdCreator.new
        end

        def import
          transactions_to_create = []

          ::CSV.foreach(@path) do |transaction|
            amount = (transaction[1].to_f * 1000).to_i
            date = Date.parse(transaction[0])

            transactions_to_create << {
              id: @import_id_creator.import_id(amount, date),
              amount: amount,
              payee_name: transaction[2],
              date: date,
              description: transaction[2]
            }
          end

          ::F2ynab::YNAB::BulkTransactionCreator.new(transactions_to_create, account_id: @ynab_account_id).create
        end
      end
    end
  end
end
