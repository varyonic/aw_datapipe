require 'test_helper'

describe AwDatapipe::PipelineObject do
  let(:activity) { AwDatapipe::CopyActivity.build(id: :activity, input: sql_query, output: s3_path, runs_on: run_host) }
  let(:database) { AwDatapipe::JdbcDatabase.build(id: :database) }
  let(:run_host) { AwDatapipe::Ec2Resource.build(id: :run_host) }
  let(:s3_path) { AwDatapipe::S3DataNode.build(id: :s3_path, name: 'S3', directory_path: '/tmp') }
  let(:sql_query) { AwDatapipe::SqlDataNode.build(id: :sql_query, database: database, table: 'Y', select_query: '*') }

  describe '#initialize' do
    it 'defaults id based on name' do
      ec2 = AwDatapipe::Ec2Resource.build(name: 'Ec2Instance')
      assert ec2.id == :ec2_instance, "id = #{ec2.id}"
    end
  end

  describe '#dependencies' do
    it 'tracks recursive dependencies' do
      dependency_ids = activity.dependencies.map(&:id)
      assert dependency_ids == [:database, :sql_query, :s3_path, :run_host], dependency_ids.inspect
    end
  end

  describe '#to_hash' do
    it 'includes :id and :name' do
      assert s3_path.to_hash == { id: :s3_path, name: 'S3', directory_path: '/tmp' }, s3_path.inspect
    end
  end
end
