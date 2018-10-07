module F2ynab
  module Webhooks
    class Monzo
      attr_accessor :webhook, :ynab_account_id, :skip_tags, :skip_foreign_currency_flag, :skip_emoji

      def initialize(webhook, ynab_account_id, skip_tags: false, skip_foreign_currency_flag: false, skip_emoji: false)
        @webhook = webhook
        @ynab_account_id = ynab_account_id

        @skip_tags = skip_tags
        @skip_foreign_currency_flag = skip_foreign_currency_flag
        @skip_emoji = skip_emoji
      end

      def import
        return { warning: :unsupported_type } unless webhook[:type] == 'transaction.created'
        return { warning: :zero_value } if webhook[:data][:amount] == 0
        return { warning: :declined } if webhook[:data][:decline_reason].present?

        payee_name = webhook[:data][:merchant].try(:[], :name)
        payee_name ||= webhook[:data][:counterparty][:name] if webhook[:data][:counterparty].present?
        payee_name ||= 'Topup' if webhook[:data][:metadata][:is_topup]
        payee_name ||= webhook[:data][:description]

        description = ''
        flag = nil

        foreign_transaction = webhook[:data][:local_currency] != webhook[:data][:currency]
        if foreign_transaction
          money = ::Money.new(webhook[:data][:local_amount].abs, webhook[:data][:local_currency])
          description.prepend("(#{money.format}) ")
          flag = 'orange' unless skip_foreign_currency_flag
        end

        unless skip_emoji
          description.prepend("#{webhook[:data][:merchant][:emoji]} ") if webhook[:data][:merchant].try(:[], :emoji)
        end

        unless skip_tags
          description << webhook[:data][:merchant][:metadata][:suggested_tags] if webhook[:data][:merchant].try(:[], :metadata).try(:[], :suggested_tags)
        end

        # If this is a split repayment, then add that to the description
        if webhook[:data][:metadata].try(:[], :p2p_initiator) == 'payment-request' && webhook[:data][:merchant].present? && webhook[:data][:counterparty].present?
          description << " (Repayment to #{webhook[:data][:counterparty][:name]})"
        end

        ::F2ynab::YNAB::TransactionCreator.new(
          id: "M#{webhook[:data][:id]}",
          date: Time.parse(webhook[:data][:created]).to_date,
          amount: webhook[:data][:amount] * 10,
          payee_name: payee_name,
          description: description.strip,
          cleared: !foreign_transaction,
          flag: flag,
          account_id: ynab_account_id
        ).create
      end
    end
  end
end
