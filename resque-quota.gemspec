# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "resque-quota"
  gem.version       = "0.0.1"
  gem.authors       = ["hisea"]
  gem.email         = ["zyinghai@gmail.com"]
  gem.description   = %q{A Resque plugin that limits the number jobs a worker can perform in a period of time.}
  gem.summary       = %q{Resque-quota plugin gives the worker class a way to specify quota and refresh peroid to limit the number of jobs performed for a worker.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'resque', "~> 1.19"
  gem.add_dependency 'resque-scheduler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mock_redis'
  gem.add_development_dependency 'resque_spec'
end
