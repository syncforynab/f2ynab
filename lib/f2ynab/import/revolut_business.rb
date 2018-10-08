module F2ynab
  module Import
    class RevolutBusiness

      BASE_URL = "https://b2b.revolut.com/api/1.0"

      def initialize(ynab_client, access_token, from: nil)
        @ynab_client = ynab_client
        @from = from
        @access_token = access_token
      end

      def import
        transactions_to_create = []
        transactions.each do |transaction|
          transactions_to_create << {
            id: "R:#{transaction[:id]}",
            amount: (transaction[:legs].first[:amount] * 1000).to_i,
            payee_name: transaction[:legs].first[:description],
            date: DateTime.parse(transaction[:created_at]),
          }
        end

        ::F2ynab::YNAB::BulkTransactionCreator.new(@ynab_client, transactions_to_create).create
      end

      private

      def transactions
        url = "/transactions"
        url = "?from=#{@from}" if @from.present?
        get(url)
      end

      def accounts
        get('/accounts')
      end

      def get(url)
        parse_response(RestClient.get(BASE_URL + url, { 'Authorization' => "Bearer #{@access_token}" }))
      end

      def parse_response(response)
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
