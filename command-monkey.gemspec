spec = Gem::Specification.new do |s|
  s.name = 'command-monkey'
  s.summary = 'Interface for interactive command-reply programs'
  s.description = 'Command Monkey runs an interactive command-line program such as irb in the background, and provides an interface to send commands and return their output.'
  s.version = '0.1'
  s.files = Dir['lib/**/*.rb']
  s.required_ruby_version = '>= 1.9.0'
  s.require_path = 'lib'
  s.author = 'Yaohan Chen'
  s.email = 'yaohan.chen@gmail.com'
  s.homepage = 'http://github.com/hagabaka/command-monkey'
end

