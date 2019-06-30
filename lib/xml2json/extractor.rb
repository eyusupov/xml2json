require 'json'
require 'nokogiri'

class Extractor
  def initialize(spec)
    @spec = spec
  end

  def extract(xml, spec: @spec)
    if spec.is_a?(Array)
      extract_dict(xml, spec)
    elsif spec['type'] == 'array'
      extract_array(xml, spec)
    elsif spec['type'] == 'hash'
      extract_hash(xml, spec)
    elsif spec.has_key?('key')
      extract_key(xml, spec)
    else
      extract_value(xml, spec)
    end
  end

  def extract_dict(xml, spec)
    spec.each_with_object(Hash.new) do |definition, hash|
      raise "Dict must have named keys" unless definition.has_key?('key')
      hash.merge!(extract_key(xml, definition))
    end
  end

  def extract_array(xml, spec)
    array = xml.css(spec['css'])
    if spec.has_key?('elements')
      array.map { |element| extract(element, spec: spec['elements']) }
    else
      element_spec = spec.reject { |k| k == 'css' }
      array.map { |element| extract_value(element, element_spec) }
    end
  end

  def extract_hash(xml, spec)
    elements = xml.css(spec['css'])
    elements.each_with_object(Hash.new) do |element, hash|
      hash.merge!(extract(element, spec: spec['key']) => extract(element, spec: spec['value']))
    end
  end

  def extract_key(xml, spec)
    key = spec['key']
    key = extract(xml, spec: key) if key.is_a?(Hash)
    {key => extract(xml, spec: spec.reject { |k| k == 'key' })}
  end

  def extract_value(xml, spec)
    value = xml
    value = xml.at(spec['css']) if spec.has_key?('css')
    value = value[spec['attr']] if spec.has_key?('attr')
    value = value.to_s
    value = value.strip if spec['trim']
    value = JSON.parse(value) if spec['type'] == 'json'
    value
  end
end
