# xml2json

Describe XML content with CSS selectors and extract it.

Example usage:

```ruby
require 'yaml'
require 'xml2json/extractor'
doc = <<~DOC
  <root>
    <b>simple value</b>
    <ul id='list'>
      <li data-value="value-1">Value 1</li>
      <li data-value="value-2">Value 2</li>
    </ul>
  </root>
DOC

spec = <<~SPEC
- key: value
  css: "b text()"
- key: list
  type: array
  css: "ul#list li"
  attr: "data-value"
SPEC

extractor = Extractor.new(YAML.load(spec))
extractor.extract(Nokogiri::XML(doc))
```

See spec file for more examples.

