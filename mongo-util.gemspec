$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mongo/util/version"

Gem::Specification.new do |s|
  s.name          = 'mongo-util'
  s.version       = Mongo::Util::VERSION
  s.date          = '2014-11-03'
  s.summary       = "Ruby Interface for copying Mongo Collections from one server to another"
  s.description   = "Uses standard mongo shell tools to provide an easy copying interface. No extra ruby mongo driver required"
  s.authors       = ["Finn-Lenanrt Heemeyer"]
  s.email         = 'finn@heemeyer.net'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/mongo-util'
  s.license       = 'MIT'

  s.add_runtime_dependency 'json'
end
