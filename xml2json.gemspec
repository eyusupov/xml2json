Gem::Specification.new do |s|
  s.name = 'xml2json'
  s.version = '0.0.1'

  s.date = '2018-01-07'
  s.authors = [
    'Eldar Yusupov (eyusupov)'
  ]
  s.email = 'eyusupov@gmail.com'

  s.licenses = ['MIT']

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.md']

  s.description = 'XML/HTML data extractor'
  s.summary = s.description

  s.add_runtime_dependency 'nokogiri'
end
