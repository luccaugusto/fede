Gem::Specification.new do |s|
  s.name        = 'fede'
  s.version     = '0.1.0'
  s.summary     = 'XML from yaml'
  s.description = 'Very Simple XML feed generator from yaml data files'
  s.authors     = ['Lucca Augusto']
  s.email       = 'lucca@luccaaugusto.xyz'
  all_files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.files         = all_files.grep(%r{^(bin|lib|rubocop)/|^.rubocop.yml$})
  s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.homepage    = 'https://github.com/luccaugusto/fede'
  s.license     = 'MIT'

  s.metadata    = {
    'source_code_uri' => 'https://github.com/luccaugusto/fede',
    'bug_tracker_uri' => 'https://github.com/luccaugusto/fede/issues',
    'changelog_uri' => 'https://github.com/luccaugusto/fede/releases',
    'homepage_uri' => s.homepage
  }
end
