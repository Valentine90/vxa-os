#==============================================================================
# ** Jsonable
#------------------------------------------------------------------------------
#  Este script converte objetos Ruby em json.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Jsonable

  JSON_OPTS = {
    array_nl: "\n",
    object_nl: "\n",
    indent: '  ',
    space_before: '',
    space: ' '
  }

  def self.load_rvdata(path_name)
    data = []
    File.open(path_name, 'rb') do |file|
      objects = Marshal.load(file)
      if objects.is_a?(Array)
        objects.each { |object| data << (object ? unpack_variables(object) : nil) }
      # Se for o System ou MapInfos
      else
        data << unpack_variables(objects)
      end
    end
    data
  end
  
  def self.unpack_variables(object)
    variables = {}
    object.instance_variables.each do |var|
      key = var.to_s.delete('@')
      value = object.instance_variable_get(var)
      if value.is_a?(Array)
        variables[key] = value.map { |v| default_class?(v) ? v : unpack_variables(v) }
      else
        variables[key] = default_class?(value) ? value : unpack_variables(value)
      end
    end
    variables
  end

  def self.default_class?(object)
    object.is_a?(Numeric) || object.is_a?(String) || object.is_a?(TrueClass) || object.is_a?(FalseClass) ||
      object.is_a?(Array) || object.is_a?(Hash) || object.is_a?(NilClass)
  end

  def self.save_to_json(file_name, data)
    File.open("json/#{file_name}.json", 'wb') { |file| file.write(JSON.generate(data, JSON_OPTS)) }
  end

end
