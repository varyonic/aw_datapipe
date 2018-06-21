module AwDatapipe
  class PipelineObject
    attr_reader :id
    attr_accessor :name
    attr_accessor :pipeline

    def self.build(params)
      new(params)
    end

    def initialize(params)
      @id = params.delete(:id) || params[:name].underscore.to_sym ||
        raise(ArgumentError, ":id or :name required: #{params.inspect}")
      params.each_pair { |k, v| send "#{k}=", v }
    end

    # Iterates through struct members, recursively collecting any PipelineObjects.
    # Recursion ensures dependencies sorted before dependents.
    def dependencies
      members.each_with_object([]) do |attr_name, depends|
        value = send(attr_name)
        value = pipeline.objects.fetch(value) if value.is_a?(Symbol)
        depends << value.dependencies << value if value.is_a?(PipelineObject)
      end.flatten
    end

    def inspect
      "#<#{type} #{to_hash}>"
    end

    # @return [Array of Symbol] Attribute names for subtype.
    def members
      instance_variables.map { |iv| iv.to_s[1..-1].to_sym } - %i(id name pipeline)
    end

    def to_hash
      members.each_with_object(id: id, name: name) { |k, h| h[k] = send(k) }
    end

    def source(indent_level = 1)
      "#{self.class.name}.build(" << [:id, :name, *members].map do |member|
        "\n" << indent(indent_level) << member_source(member)
      end.join(",") << ")"
    end

    def type
      self.class.name.split('::').last
    end

    protected

    def indent(indent_level)
      " " * 2 * indent_level
    end

    def member_source(member)
      value = send member
      value = ?' << value.gsub("'", "\\\\'") << ?' if value.is_a?(String)
      value = ":#{value}" if member == :id
      "#{member}: #{value}"
    end
  end

  class Configuration < PipelineObject
    attr_accessor :failure_and_rerun_mode, :pipeline_log_uri, :resource_role, :role, :schedule, :schedule_type
  end

  class Schedule < PipelineObject
    attr_accessor :period, :start_date_time
  end

  class S3DataNode < PipelineObject
    attr_accessor :directory_path, :data_format, :file_path
  end

  class CsvDataFormat < PipelineObject
    attr_accessor :column

    def type
      'CSV'
    end
  end

end
