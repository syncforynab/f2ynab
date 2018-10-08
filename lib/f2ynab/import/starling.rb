module F2ynab
  module Import
    class Starling
      def initialize(ynab_client, access_token, from: nil)
        @starling = ::Starling::Client.new(access_token: access_token)
        @ynab_client = ynab_client
        @from = from
      end

      def import
        from = (@from || @starling.account.get.created_at).to_date
        transactions_to_create = []
        @starling.transactions.list(params: { from: from, to: Date.today }).each do |transaction|
          transactions_to_create << {
            id: "S:#{transaction.id}",
            amount: (transaction.amount * 1000).to_i,
            payee_name: transaction.narrative.strip,
            date: transaction.created,
          }
        end

        ::F2ynab::YNAB::BulkTransactionCreator.new(@ynab_client, transactions_to_create).create
      end
    end
  end
end
