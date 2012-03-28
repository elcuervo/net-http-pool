Gem::Specification.new do |s|
  s.name              = "net-http-pool"
  s.version           = "0.0.1"
  s.summary           = "Persistent pool of connections"
  s.authors           = ["elcuervo"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/net-http-pool"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("net-http-persistent", ">= 2.6")
  s.add_dependency("celluloid", "~> 0.9.0")

  s.add_development_dependency("cutest", "~> 1.1.3")
  s.add_development_dependency("capybara", "~> 1.1.2")
  s.add_development_dependency("mock-server", "~> 0.1.2")
end
