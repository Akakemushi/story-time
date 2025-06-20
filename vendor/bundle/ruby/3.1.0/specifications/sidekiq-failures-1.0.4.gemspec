# -*- encoding: utf-8 -*-
# stub: sidekiq-failures 1.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-failures".freeze
  s.version = "1.0.4".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marcelo Silveira".freeze]
  s.date = "2022-09-03"
  s.description = "Keep track of Sidekiq failed jobs".freeze
  s.email = ["marcelo@mhfs.com.br".freeze]
  s.homepage = "https://github.com/mhfs/sidekiq-failures/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Keeps track of Sidekiq failed jobs and adds a tab to the Web UI to let you browse them. Makes use of Sidekiq's custom tabs and middleware chain.".freeze

  s.installed_by_version = "3.5.6".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 4.0.0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rack-test>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<sprockets>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<sinatra>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
end
