Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0'
  s.name        = 'fede'
  s.version     = '0.1.3'
  s.summary     = 'XML from yaml'
  s.description = 'Very Simple XML feed generator from yaml data files'
  s.authors     = ['Lucca Augusto']
  s.email       = 'lucca@luccaaugusto.xyz'
  all_files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.files         = all_files.grep(%r{^(bin|lib|rubocop)/|^.rubocop.yml$})
  s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.homepage    = 'https://github.com/luccaugusto/fede'
  s.license     = 'MIT'
end
