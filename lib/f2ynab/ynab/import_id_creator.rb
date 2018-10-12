module F2ynab
  module YNAB
    class ImportIdCreator
      def initialize
        @occurence = {}
      end

      def import_id(amount, date)
        key = ['YNAB', amount, date].join(':')
        @occurence[key] ||= 0
        @occurence[key] += 1
        key + ":#{@occurence[key]}"
      end
    end
  end
end
