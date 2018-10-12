require "test_helper"
require "f2ynab/ynab/client"

class TestYnabClient < Minitest::Test
  def test_it_can_be_initialized
    client = F2ynab::YNAB::Client.new("access_token", "budget_id", "account_id")
    assert_instance_of F2ynab::YNAB::Client, client
  end
end
