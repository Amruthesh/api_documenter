$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "api_documenter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_documenter"
  s.version     = ApiDocumenter::VERSION
  s.authors     = ["Amruthesh"]
  s.email       = ["amruthesh.g@jifflenow.com"]
  s.homepage    = "https://github.com/Amruthesh/api_documenter.git"
  s.summary     = "Gem to generate skeleton of a API response"
  s.description = "Gem to generate skeleton of a API response"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_development_dependency "sqlite3"
end
