require 'csv'

# @note This is used to import Amex CSV Statements
# Export the statement CSV from within the web app

module F2ynab
  module Import
    module Csv
      class Amex
        def initialize(ynab_client, path)
          @path = path
          @ynab_client = ynab_client
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

          ::F2ynab::YNAB::BulkTransactionCreator.new(@ynab_client, transactions_to_create).create
        end
      end
    end
  end
end
