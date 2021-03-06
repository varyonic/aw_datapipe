module AwDatapipe

  class Pipeline
    attr_accessor :id # AWS pipeline id
    attr_accessor :uuid # Unique id
    attr_reader :objects # ObjectHash[:id => PipelineObject]
    attr_reader :parameter_metadata # Hash['parameterName' => Hash[type:|default:|description:|...]
    attr_reader :parameter_values # Hash['parameterName' => "value"]

    # objects [Array]
    def initialize(objects, parameter_metadata, parameter_values)
      @objects = ObjectHash.new
      append_objects_with_dependencies(objects)
      @parameter_metadata, @parameter_values = parameter_metadata, parameter_values
      yield(self) if block_given?
    end

    def self.build(config, activities, parameter_metadata, parameter_values)
      new([config], parameter_metadata, parameter_values) do |pipeline|
        pipeline.append_objects_with_dependencies(activities)
      end
    end

    # @return [PipelineObject] appended object
    def append_object(object)
      object.pipeline = self
      objects[object.id] = object
    end

    def append_object_with_dependencies(object)
      [*object.dependencies, object].each(&method(:append_object))
    end

    # @return [Pipeline] self
    def append_objects_with_dependencies(objects)
      objects.each(&method(:append_object_with_dependencies))
      self
    end

    def configuration
      objects.fetch(:default)
    end

    def csv_data_format(params)
      append_object CsvDataFormat.build(params)
    end

    # @param [Hash] params Various required and optional parameters.
    # @option params [String] :name (default: 'Ec2Instance')
    # @option params [String] :instance_type (default: 't1.micro')
    # @option params [String] :subnet_id
    # @option params [String] :security_group_ids
    # @option params [String] :action_on_task_failure (default: 'terminate')
    # @option params [String] :terminate_after (default: '2 Hours')
    # 
    # @return [Ec2Resource]
    def ec2_resource(params)
      append_object Ec2Resource.build(
        { name: 'Ec2Instance', instance_type: 't1.micro', action_on_task_failure: 'terminate', terminate_after: '2 Hours' }.merge(params))
    end

    def jdbc_database(params)
      append_object JdbcDatabase.build(params)
    end

    def s3_data_node(params)
      append_object S3DataNode.build(params)
    end

    def referenced_object_ids
      referenced_objects.map(&:id) << :default
    end

    # Collect dependencies for all objects, removing duplicates.
    # @return [Array] referenced objects, with dependees before dependents.
    def referenced_objects
      objects.values.map(&:dependencies).flatten.uniq
    end

    def write_source(pathname)
      SourceWriter.call(self, pathname)
    end
  end
end
