require 'yaml'
require 'xml2json/extractor'

RSpec.describe Extractor do
  let(:document) {
  <<~DOC
  <root>
    <b>simple value</b>
    <ul id='list'>
      <li data-value="value-1">Value 1</li>
      <li data-value="value-2">Value 2</li>
    </ul>
    <ul id='json-list'>
      <li data-value='{"val": "value-1"}'>Value 1</li>
      <li data-value='{"val": "value-2"}'>Value 2</li>
    </ul>
    <table id='hash'>
      <tr><td class='id'>Key 1</td><td class='value'>Value 1</td></tr>
      <tr><td class='id'>Key 2</td><td class='value'>Value 2</td></tr>
    </table>
    <div id='dict'>
      <div class='name'>Name</div>
      <addr class='address'>Address</addr>
    </div>
  </root>
  DOC
  }

  subject { described_class.new(spec).extract(xml) }
    let(:xml) { Nokogiri::XML(document) }
    let(:spec) { YAML.load(spec_yaml) }

  context 'single value' do
    let(:spec_yaml) { 'css: "b text()"' }

    it { is_expected.to eq('simple value') }
  end

  context 'named value' do
    let(:spec_yaml) { <<~SPEC
                      key: key
                      css: "root b text()"
                      SPEC
    }

    it { is_expected.to eq({'key' => 'simple value'}) }
  end

  # TODO: test trim

  context 'single attribute' do
    let(:spec_yaml) { <<~SPEC
                      css: "root > div"
                      attr: id
                      SPEC
    }

    it { is_expected.to eq('dict') }
  end

  context 'unnamed value in dict' do
    let(:spec_yaml) { <<~SPEC
                      - css: "root b text()"
                      SPEC
    }

    specify { expect { subject }.to raise_error("Dict must have named keys") }
  end

  context 'dict' do
    let(:spec_yaml) { <<~SPEC
                      - key: name
                        css: "div div text()"
                      - key: address
                        css: "div addr text()"
                      SPEC
    }

    it { is_expected.to eq({'name' => 'Name', 'address' => 'Address'}) }
  end

  context 'simple list' do
    let(:spec_yaml) { <<~SPEC
                      type: array
                      css: "ul#list li text()"
                      SPEC
    }

    it { is_expected.to eq(['Value 1', 'Value 2']) }
  end

  context 'simple list with attr' do
    let(:spec_yaml) { <<~SPEC
                      type: array
                      css: "ul#list li"
                      attr: "data-value"
                      SPEC
    }

    it { is_expected.to eq(['value-1', 'value-2']) }
  end

  context 'simple list with json typed attr' do
    let(:spec_yaml) { <<~SPEC
                      type: array
                      css: "ul#json-list li"
                      elements:
                        attr: "data-value"
                        type: json
                      SPEC
    }

    it { is_expected.to eq([{'val' => 'value-1'}, {'val' => 'value-2'}]) }
  end

  context 'list of dicts' do
    let(:spec_yaml) { <<~SPEC
                      type: array
                      css: "table#hash tr"
                      elements:
                      - key: id
                        css: ".id text()"
                      - key: value
                        css: ".value text()"
                      SPEC
    }

    it { is_expected.to eq([{'id' => 'Key 1', 'value' => 'Value 1'}, {'id' => 'Key 2', 'value' => 'Value 2'}]) }
  end

  context 'hash with list' do
    let(:spec_yaml) { <<~SPEC
                      - key: name
                        css: "div div text()"
                      - key: list
                        type: array
                        css: "ul#list li text()"
                      SPEC
    }

    it { is_expected.to eq({'name' => 'Name', 'list' => ['Value 1', 'Value 2']}) }
  end

  context 'dynamic hash' do
    let(:spec_yaml) { <<~SPEC
                      type: hash
                      css: "div#dict *"
                      key:
                        attr: class
                      value:
                        css: "text()"
                      SPEC
    }

    it { is_expected.to eq({'name' => 'Name', 'address' => 'Address'}) }
  end
end
