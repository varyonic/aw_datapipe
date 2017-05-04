module AwDatapipe
  class PipelineObject < Struct
    attr_accessor :id
    attr_accessor :name
    attr_accessor :pipeline

    def self.build(params)
      new.tap do |struct|
        params.each_pair { |k, v| struct.send "#{k}=", v }
      end
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

    def demodulized_class_name
      self.class.name.split('::').last
    end

    def inspect
      "#<#{demodulized_class_name} #{to_hash}>"
    end

    def to_hash
      Hash[each_pair.to_a].merge(id: id, name: name)
    end

    def source(indent_level = 1)
      "#{self.class.name}.build(" << [:id, :name, *members].map do |member|
        "\n" << indent(indent_level) << member_source(member)
      end.join(",") << ")"
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

  Configuration = PipelineObject.new(:failure_and_rerun_mode, :pipeline_log_uri, :resource_role, :role, :schedule, :schedule_type)
  Schedule = PipelineObject.new(:period, :start_date_time)

  Ec2Resource = PipelineObject.new(:action_on_task_failure, :instance_type, :security_group_ids, :subnet_id, :terminate_after)
  S3DataNode = PipelineObject.new(:directory_path)

  JdbcDatabase = PipelineObject.new(:_password, :connection_string, :jdbc_driver_class, :username)
  SqlDataNode = PipelineObject.new(:database, :select_query, :table)
  CopyActivity = PipelineObject.new(:input, :output, :runs_on)

  RedshiftDatabase = PipelineObject.new(:_password, :connection_string, :database_name, :username)
  RedshiftDataNode = PipelineObject.new(:create_table_sql, :database, :primary_keys, :schema_name, :table_name)
  RedshiftCopyActivity = PipelineObject.new(:input, :insert_mode, :output, :runs_on)

end
