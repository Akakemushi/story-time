# -*- encoding: utf-8 -*-
# stub: cloudinary 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cloudinary".freeze
  s.version = "2.3.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/cloudinary/cloudinary_gem/blob/master/CHANGELOG.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nadav Soferman".freeze, "Itai Lahan".freeze, "Tal Lev-Ami".freeze]
  s.date = "2025-02-20"
  s.description = "Client library for easily using the Cloudinary service".freeze
  s.email = ["nadav.soferman@cloudinary.com".freeze, "itai.lahan@cloudinary.com".freeze, "tal.levami@cloudinary.com".freeze]
  s.homepage = "https://cloudinary.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 3".freeze)
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Client library for easily using the Cloudinary service".freeze

  s.installed_by_version = "3.5.6".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, [">= 2.0.1".freeze, "< 3.0.0".freeze])
  s.add_runtime_dependency(%q<faraday-multipart>.freeze, ["~> 1.0".freeze, ">= 1.0.4".freeze])
  s.add_runtime_dependency(%q<faraday-follow_redirects>.freeze, ["~> 0.3.0".freeze])
  s.add_runtime_dependency(%q<ostruct>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rails>.freeze, [">= 6.1.7".freeze, "< 8.0.0".freeze])
  s.add_development_dependency(%q<rexml>.freeze, [">= 3.2.5".freeze, "< 4.0.0".freeze])
  s.add_development_dependency(%q<actionpack>.freeze, [">= 6.1.7".freeze, "< 8.0.0".freeze])
  s.add_development_dependency(%q<nokogiri>.freeze, [">= 1.12.5".freeze, "< 2.0.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 13.0.6".freeze, "< 14.0.0".freeze])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 1.4.2".freeze, "< 2.0.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.11.2".freeze, "< 4.0.0".freeze])
  s.add_development_dependency(%q<rspec-retry>.freeze, [">= 0.6.2".freeze, "< 1.0.0".freeze])
  s.add_development_dependency(%q<railties>.freeze, [">= 6.0.4".freeze, "< 8.0.0".freeze])
  s.add_development_dependency(%q<rspec-rails>.freeze, [">= 6.0.4".freeze, "< 7.0.0".freeze])
  s.add_development_dependency(%q<rubyzip>.freeze, [">= 2.3.0".freeze, "< 3.0.0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0.21.2".freeze, "< 1.0.0".freeze])
end
