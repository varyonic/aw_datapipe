module AwDatapipe
  # Converts a pipeline into a format that can be submitted to the AWS client SDK.
  class PipelineSerializer
    def marshal(pipeline)
      {
        pipeline_id: pipeline.id,
        pipeline_objects: marshal_pipeline_objects(pipeline),
        parameter_objects: marshal_parameter_objects(pipeline.parameter_metadata),
        parameter_values: marshal_parameter_values(pipeline.parameter_values)
      }
    end

    def unmarshal(aws_definition)
      # pipeline.aws_definition = aws_definition # for troubleshooting
      objects = unmarshal_pipeline_objects(aws_definition.pipeline_objects)
      parameter_metadata = unmarshal_parameter_objects(aws_definition.parameter_objects)
      parameter_values = unmarshal_parameter_values(aws_definition.parameter_values)

      Pipeline.new(objects, parameter_metadata, parameter_values)
    end

    protected

    def marshal_pipeline_objects(pipeline)
      # marshal referenced objects before unreferenced.
      referenced_object_ids = pipeline.referenced_object_ids
      unreferenced_object_ids = pipeline.objects.keys - referenced_object_ids
      ids = (referenced_object_ids + unreferenced_object_ids)

      ids.each_with_object([]) do |id, out|
        out << marshal_pipeline_object(pipeline.objects[id])
      end
    end

    def marshal_pipeline_object(pipeline_object)
      type = pipeline_object.type
      hash = pipeline_object.to_hash
      id = hash.delete(:id)
      name = hash.delete(:name)
      fields = hash_to_fields(hash)
      fields << { key: 'type', string_value: type } unless type == 'Configuration'
      Hash[id: camelize(id), name: name, fields: fields]
    end

    # @return Array PipelineObject subclass instance.
    def unmarshal_pipeline_objects(pipeline_objects)
      pipeline_objects.map do |aws_struct|
        unmarshal_pipeline_object(aws_struct)
      end
    end

    # @return PipelineObject subclass instance.
    def unmarshal_pipeline_object(aws_struct)
      attributes = fields_to_hash(aws_struct.fields)
      type = attributes.delete(:type) || 'Configuration'
      attributes.merge!(id: symbolize(aws_struct.id), name: aws_struct.name)

      klass = AwDatapipe.const_defined?(type, false) ?
        AwDatapipe.const_get(type, false) :
        AwDatapipe.const_set(type, PipelineObject.new(*(attributes.keys - [:id, :name])))

      klass.new(attributes)
    end

    def fields_to_hash(fields)
      fields.each_with_object({}) do |field, hash|
        if hash[symbolize field.key]
          hash[symbolize field.key] = Array(hash[symbolize field.key]) << field.string_value
        else
          hash[symbolize field.key] = field.string_value || field.ref_value.underscore.to_sym
        end
      end
    end

    def hash_to_fields(hash)
      hash.each_pair.map do |key, value|
        camelized_key = camelize(key, :lower)
        case value
        when PipelineObject
          { key: camelized_key, ref_value: camelize(value.id) }
        when Array
          value.map { |v| Hash[key: camelized_key, string_value: v] }
        when NilClass
        else
          { key: camelized_key, string_value: value }
        end
      end.flatten.compact
    end

    # Convert string to a rubyish variable name.
    def symbolize(key)
      key.underscore.gsub('*','_').to_sym
    end

    # Convert symbol back to AWSish name.
    def camelize(key, term = :upper)
      key.to_s.sub(/^\_/, '*').camelize(term)
    end

    def marshal_parameter_objects(parameter_metadata)
      parameter_metadata.map { |key, hash| marshal_parameter_object(key, hash) }
    end

    def marshal_parameter_object(key, hash)
      out = []
      hash.each_pair do |k, v|
        out << { key: k, string_value: v }
      end
      { id: key, attributes: out }
    end

    def unmarshal_parameter_objects(parameter_objects)
      parameter_objects.each_with_object({}) do |object, hash|
        klass = ParameterMetadata.new(*object.attributes.map(&:key).map(&:to_sym))
        hash[object.id] = object.attributes.each_with_object(klass.new) do |attribute, struct|
          struct.send "#{attribute.key}=", attribute.string_value
        end
      end
    end

    def marshal_parameter_values(parameter_values)
      out = []
      parameter_values.each_pair do |id, value|
        if value.respond_to?(:each)
          value.each { |v| out << { id: id, string_value: v } }
        else
          out << { id: id, string_value: value }
        end
      end
      out
    end

    def unmarshal_parameter_values(parameter_values)
      parameter_values.each_with_object({}) do |value, hash|
        if hash[value.id]
          hash[value.id] = Array(hash[value.id]) << value.string_value
        else
          hash[value.id] = value.string_value
        end
      end
    end
  end
end
