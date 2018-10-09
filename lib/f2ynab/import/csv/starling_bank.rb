require 'csv'

# @note This is used to import Starling Bank CSV Statements
# Export the statement CSV from within the app

module F2ynab
  module Import
    module Csv
      class StarlingBank
        def initialize(ynab_client, path)
          @path = path
          @ynab_client = ynab_client
          @import_id_creator = ::F2ynab::YNAB::ImportIdCreator.new
        end

        def import
          transactions_to_create = []

          ::CSV.foreach(@path, headers: true) do |transaction|
            # First row can be blank
            next unless transaction['Date'].present?

            amount = (transaction['Amount (GBP)'].to_f * 1000).to_i
            date = Date.parse(transaction['Date'])

            transactions_to_create << {
              id: @import_id_creator.import_id(amount, date),
              amount: amount,
              payee_name: transaction['Counter Party'],
              date: date,
              description: transaction['Reference'],
            }
          end

          ::F2ynab::YNAB::BulkTransactionCreator.new(@ynab_client, transactions_to_create).create
        end
      end
    end
  end
end
