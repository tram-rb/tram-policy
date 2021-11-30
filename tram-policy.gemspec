Gem::Specification.new do |gem|
  gem.name     = "tram-policy"
  gem.version  = "2.0.1"
  gem.author   = ["Viktor Sokolov (gzigzigzeo)", "Andrew Kozin (nepalez)"]
  gem.email    = "andrew.kozin@gmail.com"
  gem.homepage = "https://github.com/tram-rb/tram-policy"
  gem.summary  = "Policy Object Pattern"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]
  gem.executables      = %w[tram-policy]

  gem.required_ruby_version = ">= 2.3"

  gem.add_runtime_dependency "dry-initializer", "> 2", "< 4"
  gem.add_runtime_dependency "i18n", "~> 1.0"

  gem.add_development_dependency "rake", "> 10"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rspec-its", "~> 1.2"
  gem.add_development_dependency "rubocop", "~> 0.49"
  gem.add_development_dependency "thor", "~> 0.19"
end
