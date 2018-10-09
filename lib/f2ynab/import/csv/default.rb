require 'csv'

# @note The CSV must contain: amount, description and date (YYYY-MM-DD)
# @note the amount must be the full value (so $100 would be 100)

module F2ynab
  module Import
    module Csv
      class Default
        FORMATS = {
          'default'   => '::F2ynab::Import::Csv',
          'starling'  => '::F2ynab::Import::Csv::StarlingBank',
          'mbna'      => '::F2ynab::Import::Csv::MBNA',
          'amex'      => '::F2ynab::Import::Csv::Amex',
        }

        def initialize(ynab_client, path)
          @path = path
          @ynab_client = ynab_client
          @import_id_creator = ::F2ynab::YNAB::ImportIdCreator.new
        end

        def import
          transactions_to_create = []

          ::CSV.foreach(@path, headers: true) do |transaction|
            transaction = transaction.to_h.symbolize_keys
            amount = (transaction[:amount].to_f * 1000).to_i
            date = Date.parse(transaction[:date])

            transactions_to_create << {
              id: @import_id_creator.import_id(amount, date),
              amount: amount,
              payee_name: transaction[:description],
              date: date,
            }
          end

          ::F2ynab::YNAB::BulkTransactionCreator.new(@ynab_client, transactions_to_create).create
        end
      end
    end
  end
end
