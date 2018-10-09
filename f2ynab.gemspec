
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "f2ynab/version"

Gem::Specification.new do |spec|
  spec.name          = "f2ynab"
  spec.version       = F2ynab::VERSION
  spec.authors       = ["Scott Robertson"]
  spec.email         = ["scottymeuk@gmail.com"]

  spec.summary       = %q{Fintech to YNAB Library}
  spec.description   = %q{Fintech to YNAB Library}
  spec.homepage      = "https://github.com/fintech-to-ynab"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "money", "~> 6.13"
  spec.add_runtime_dependency "ynab", "~> 1.5"
  spec.add_runtime_dependency "starling-ruby", "~> 0.2"
  spec.add_runtime_dependency "rest-client", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "rubocop", "~> 0.59"
end
