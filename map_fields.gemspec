Gem::Specification.new do |s|
  s.name = %q{map_fields}
  s.version = "2.0.0.beta2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Timberlake"]
  s.date = %q{2011-06-13}
  s.email = %q{andrew@andrewtimberlake.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
  ] + Dir['lib/**/*.rb'] + Dir['views/**/*.erb']
  s.homepage = %q{http://github.com/internuity/map-fields}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Rails gem to allow a user to map the fields of a CSV to an expected list of fields}
  s.test_files = Dir['spec/**']

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
