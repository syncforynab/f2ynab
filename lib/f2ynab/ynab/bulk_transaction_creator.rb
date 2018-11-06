module F2ynab
  module YNAB
    class BulkTransactionCreator
      BATCH_SIZE = 100

      def initialize(client, transactions)
        @transactions = transactions
        @client = client
      end

      def create
        if @transactions.size.zero?
          Rails.logger.info(:no_transactions_to_create)
          return false
        end

        created_transactions_ids = []
        batches = (@transactions.size.to_f / BATCH_SIZE).ceil

        Rails.logger.info("Splitting #{@transactions.size} transactions into #{batches} batches")

        @transactions.each_slice(BATCH_SIZE).with_index do |transactions, index|
          Rails.logger.info("Processing batch #{index + 1} of #{batches}")

          transactions_to_create = []
          transactions.each do |transaction|
            transactions_to_create << {
              import_id: transaction[:id].to_s.truncate(36),
              account_id: @client.selected_account_id,
              payee_name: transaction[:payee_name].to_s.truncate(50),
              amount: transaction[:amount],
              memo: transaction[:description],
              date: transaction[:date].to_date,
              cleared: transaction[:cleared] ? 'Cleared' : 'Uncleared',
              flag: transaction[:flag],
            }
          end

          if transactions_to_create.any?
            create_transactions = @client.create_transactions(transactions_to_create)
            Rails.logger.info(create_transactions)
            created_transactions_ids.merge!(create_transactions.transaction_ids)
          else
            Rails.logger.info(:no_transactions_to_create)
          end
        end
        
        created_transactions_ids
      end
    end
  end
end
