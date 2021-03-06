require 'test_helper'

describe AwDatapipe::Pipeline do
  let(:config) { AwDatapipe::Configuration.build(id: :default) }

  let(:activity) { AwDatapipe::CopyActivity.build(id: :activity, input: sql_query, output: s3_path, runs_on: run_host) }
  let(:database) { AwDatapipe::JdbcDatabase.build(id: :database) }
  let(:run_host) { AwDatapipe::Ec2Resource.build(id: :run_host) }
  let(:s3_path) { AwDatapipe::S3DataNode.build(id: :s3_path, name: 'S3', directory_path: '/tmp') }
  let(:sql_query) { AwDatapipe::SqlDataNode.build(id: :sql_query, database: database, table: 'Y', select_query: '*') }

  let(:parameter_metadata) { Hash[] }
  let(:parameter_values) { Hash[] }

  describe '#build' do
    it 'adds dependencies to the objects hash' do
      pipeline = AwDatapipe::Pipeline.build(config, [activity], parameter_metadata, parameter_values)

      assert pipeline.objects.keys == [:default, :database, :sql_query, :s3_path, :run_host, :activity], pipeline.objects.keys.inspect
    end

    it 'supports block syntax' do
      pipeline = AwDatapipe::Pipeline.new([config], parameter_metadata, parameter_values) do |pl|
        database = pl.jdbc_database(id: :database)
        sql_query = database.sql_data_node(id: :sql_query, table: 'Y', select_query: '*')
        s3_path = pl.s3_data_node(id: :s3_path, name: 'S3', directory_path: '/tmp')
        run_host = pl.ec2_resource(id: :run_host)

        run_host.copy_activity(id: :activity, input: sql_query, output: s3_path)
      end

      assert pipeline.objects.keys == [:default, :database, :sql_query, :s3_path, :run_host, :activity], pipeline.objects.keys.inspect
    end
  end
end
