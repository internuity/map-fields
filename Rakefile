# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'map_fields'

task :default => 'spec:run'

PROJ.name = 'map-fields'
PROJ.authors = 'Andrew Timberlake'
PROJ.email = 'andrew@andrewtimberlake.com'
PROJ.url = 'http://github.com/internuity/map-fields'
PROJ.version = MapFields::VERSION
PROJ.rubyforge.name = 'internuity'
PROJ.readme_file = 'README.rdoc'
PROJ.gem.files = FileList['lib/**/**', 'views/**/**', 'README.rdoc', 'init.rb', 'History.txt']

PROJ.exclude = %w(spec/rails_root)

PROJ.rdoc.remote_dir = 'map-fields'

PROJ.spec.opts << '--color'

depend_on 'fastercsv'

# EOF
