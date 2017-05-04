module AwDatapipe

  class Pipeline
    attr_accessor :id # AWS pipeline id
    attr_accessor :uuid # Unique id
    attr_reader :objects # ObjectHash[:id => PipelineObject]
    attr_reader :parameter_metadata # Hash['parameterName' => Hash[type:|default:|description:|...]
    attr_reader :parameter_values # Hash['parameterName' => "value"]

    # objects [Array]
    def initialize(objects, parameter_metadata, parameter_values)
      objects.each { |object| object.pipeline = self }
      @objects ||= ObjectHash.new(*objects)
      @parameter_metadata, @parameter_values = parameter_metadata, parameter_values
    end

    def self.build(config, activities, parameter_metadata, parameter_values)
      new([], parameter_metadata, parameter_values).tap { |p| p.objects.append_with_dependents(config, *activities) }
    end

    def configuration
      objects.fetch(:default)
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
