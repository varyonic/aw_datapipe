module AwDatapipe
  class PipelineObject < Struct
    attr_accessor :pipeline

    def self.build(params)
      new.tap do |struct|
        params.each_pair { |k, v| struct.send "#{k}=", v }
      end
    end

    # Iterates through struct members, recursively collecting any PipelineObjects.
    # Recursion ensures dependencies sorted before dependents.
    def dependencies
      (members - [:id]).each_with_object([]) do |attr_name, depends|
        value = send(attr_name)
        value = pipeline.objects.fetch(value) if value.is_a?(Symbol)
        depends << value.dependencies << value if value.is_a?(PipelineObject)
      end.flatten
    end

    def demodulized_class_name
      self.class.name.split('::').last
    end

    def to_hash
      Hash[each_pair.to_a]
    end

    def source(indent_level = 1)
      "#{self.class.name}.build(\n" << indent(indent_level) << members.map do |member|
        member_source(member)
      end.join(",\n" << indent(indent_level)) << ")"
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

  Configuration = PipelineObject.new(:failure_and_rerun_mode, :id, :name, :pipeline_log_uri, :resource_role, :role, :schedule, :schedule_type)
  Schedule = PipelineObject.new(:id, :name, :period, :start_date_time)

  Ec2Resource = PipelineObject.new(:action_on_task_failure, :id, :instance_type, :name, :security_group_ids, :subnet_id, :terminate_after)
  S3DataNode = PipelineObject.new(:directory_path, :id, :name)

  JdbcDatabase = PipelineObject.new(:_password, :connection_string, :id, :jdbc_driver_class, :name, :username)
  SqlDataNode = PipelineObject.new(:database, :id, :name, :select_query, :table)
  CopyActivity = PipelineObject.new(:id, :input, :name, :output, :runs_on)

  RedshiftDatabase = PipelineObject.new(:_password, :connection_string, :database_name, :id, :name, :username)
  RedshiftDataNode = PipelineObject.new(:create_table_sql, :database, :id, :name, :primary_keys, :schema_name, :table_name)
  RedshiftCopyActivity = PipelineObject.new(:id, :input, :insert_mode, :name, :output, :runs_on)

end
