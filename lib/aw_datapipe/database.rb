require_relative 'pipeline_object'

module AwDatapipe

  class JdbcDatabase < PipelineObject
    attr_accessor :_password, :connection_string, :jdbc_driver_class, :username

    def sql_data_node(params)
      pipeline.append_object SqlDataNode.build(params.merge(database: self))
    end
  end

  class SqlDataNode < PipelineObject
    attr_accessor :database, :select_query, :table
  end

  class RedshiftDatabase < PipelineObject
    attr_accessor :_password, :connection_string, :database_name, :username
  end

  class RedshiftDataNode < PipelineObject
    attr_accessor :create_table_sql, :database, :primary_keys, :schema_name, :table_name
  end
end
