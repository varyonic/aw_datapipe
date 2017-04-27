require 'securerandom'

module AwDatapipe
  class Session
    def aws
      @aws ||= Aws::DataPipeline::Client.new
    end

    def download_definition(id, dir)
      fetch(id).write_source(dir)
    end

    # name [String] required
    # description [String] (optional)
    # unique_id [String] (default: uuid)
    def create(name, description, unique_id = SecureRandom.uuid)
      resp = aws.create_pipeline(name: name, unique_id: unique_id)
      resp.pipeline_id
    end

    def keys
      @keys ||= begin
        resp = aws.list_pipelines
        id_names = resp.pipeline_id_list
        id_names.map(&:id)
      end
    end

    def fetch(key)
      resp = aws.get_pipeline_definition(pipeline_id: key)
      serializer.unmarshal(resp).tap { |p| p.id = key }
    end

    def serializer
      @serializer = PipelineSerializer.new
    end

    def save(pipeline)
      resp = aws.put_pipeline_definition(serializer.marshal(pipeline))
      if resp.errored
        resp.validation_errors.each do |error|
          puts "Error in #{error.id}: #{error.errors.inspect}"
        end
      end
      resp.validation_warnings.each do |warning|
        puts "Warning in #{warning.id}: #{warning.warnings.inspect}"
      end
      !resp.errored
    end
  end
end
