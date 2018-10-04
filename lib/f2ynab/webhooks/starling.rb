module F2ynab
  module Webhooks
    class Starling
      WEBHOOKS_TYPES = [
        'TRANSACTION_AUTH_DECLINED',
        'TRANSACTION_AUTH_PARTIAL_REVERSAL',
        'TRANSACTION_AUTH_FULL_REVERSAL',
        'TRANSACTION_CARD',
        'TRANSACTION_CASH_WITHDRAWAL',
        'TRANSACTION_DECLINED_INSUFFICIENT_FUNDS',
        'TRANSACTION_DIRECT_CREDIT',
        'TRANSACTION_DIRECT_DEBIT',
        'TRANSACTION_DIRECT_DEBIT_INSUFFICIENT_FUNDS',
        'TRANSACTION_DIRECT_DEBIT_DISPUTE',
        'TRANSACTION_DECLINED_INSUFFICIENT_FUNDS',
        'TRANSACTION_FASTER_PAYMENT_IN',
        'TRANSACTION_FASTER_PAYMENT_OUT',
        'TRANSACTION_FASTER_PAYMENT_REVERSAL',
        'TRANSACTION_INTEREST_PAYMENT',
        'TRANSACTION_INTERNAL_TRANSFER',
        'TRANSACTION_INTEREST_WAIVED_DEPOSIT',
        'TRANSACTION_NOSTRO_DEPOSIT',
        'TRANSACTION_MOBILE_WALLET',
        'SCHEDULED_PAYMENT_CANCELLED',
        'SCHEDULED_PAYMENT_INSUFFICIENT_FUNDS',
        'TRANSACTION_STRIPE_FUNDING',
        'INTEREST_CHARGE',
      ]

      attr_accessor :webhook, :ynab_account_id

      def initialize(webhook, ynab_account_id)
        @webhook = webhook
        @ynab_account_id = ynab_account_id
      end

      def import
        return { warning: :unsupported_type } unless webhook[:webhookType].in?(WEBHOOKS_TYPES)

        payee_name = webhook[:content][:counterParty]
        amount = (webhook[:content][:amount].to_f * 1000).to_i
        description = webhook[:content][:forCustomer].to_s
        flag = nil

        foreign_transaction = webhook[:content][:sourceCurrency] != 'GBP'
        if foreign_transaction && !ENV['SKIP_FOREIGN_CURRENCY_FLAG']
          flag = 'orange'
        end

        ::F2ynab::YNAB::TransactionCreator.new(
          id: "S:#{webhook[:content][:transactionUid]}",
          date: Time.parse(webhook[:timestamp]).to_date,
          amount: amount,
          payee_name: payee_name,
          description: description.strip,
          cleared: !foreign_transaction,
          flag: flag,
          account_id: ynab_account_id || ENV['YNAB_STARLING_ACCOUNT_ID']
        ).create
      end
    end
  end
end
