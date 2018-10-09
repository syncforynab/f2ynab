require "simplecov"
SimpleCov.start do
  add_group "YNAB", "lib/f2ynab/ynab"
  add_group "Webhooks", "lib/f2ynab/webhooks"
  add_group "Import", "lib/f2ynab/import"
end

# This ensures the tests when when called directly, or via rake test
require "minitest/autorun"

# We now the entire library to get detailed coverage report and not skip files
require "f2ynab"
