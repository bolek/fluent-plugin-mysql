# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-mysql-simple-json"
  gem.version       = "0.0.7"
  gem.authors       = ["Bolek Kurowski", "TAGOMORI Satoshi"]
  gem.email         = ["bolek@alumni.cmu.edu", "tagomoris@gmail.com"]
  gem.description   = %q{fluent plugin to insert mysql as tag, time, event json}
  gem.summary       = %q{fluent plugin to insert mysql}
  gem.homepage      = "https://github.com/tagomoris/fluent-plugin-mysql"
  gem.license       = "APLv2"

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "mysql2-cs-bind"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
end
