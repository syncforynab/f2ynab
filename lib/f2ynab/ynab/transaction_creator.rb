module F2ynab
  module YNAB
    class TransactionCreator
      def initialize(id: nil, date: nil, amount: nil, payee_name: nil, description: true, flag: nil, cleared: true, budget_id: nil, account_id: nil)
        @id = id
        @date = date
        @amount = amount
        @payee_name = payee_name
        @description = description
        @cleared = cleared
        @flag = flag
        @client = ::F2ynab::YNAB::Client.new(ENV['YNAB_ACCESS_TOKEN'], budget_id, account_id)
      end

      def create
        create = @client.create_transaction(
          id: @id.to_s.truncate(36),
          payee_name: @payee_name.to_s.truncate(50),
          amount: @amount,
          cleared: @cleared,
          date: @date.to_date,
          memo: @description,
          flag: @flag
        )

        create.try(:id).present? ? create : { error: :failed, data: create }
      end
    end
  end
end
