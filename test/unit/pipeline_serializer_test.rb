require 'test_helper'

describe AwDatapipe::PipelineSerializer do
  let(:config) { AwDatapipe::Configuration.build(id: :default) }

  let(:activity) { AwDatapipe::CopyActivity.build(id: :activity, input: sql_query, output: s3_path, runs_on: run_host) }
  let(:database) { AwDatapipe::JdbcDatabase.build(id: :database) }
  let(:run_host) { AwDatapipe::Ec2Resource.build(id: :run_host, security_group_ids: ['group1', 'group2']) }
  let(:s3_path) { AwDatapipe::S3DataNode.build(id: :s3_path, name: 'S3', directory_path: '/tmp') }
  let(:sql_query) { AwDatapipe::SqlDataNode.build(id: :sql_query, database: database, table: 'Y', select_query: '*') }

  let(:parameter_metadata) { Hash[] }
  let(:parameter_values) { Hash[] }
  let(:pipeline) { AwDatapipe::Pipeline.build(config, [activity], parameter_metadata, parameter_values) }

  subject { AwDatapipe::PipelineSerializer.new }  

  describe '#marsal' do
    it 'returns an AWS definition' do
      aws_definition = subject.marshal(pipeline)
      assert aws_definition.keys == %i(pipeline_id pipeline_objects parameter_objects parameter_values)
      assert aws_definition[:pipeline_objects][3][:fields].select { |f| f[:key] == 'securityGroupIds' }.size == 2
    end
  end

  let(:aws_pipeline_objects) { [] }
  let(:aws_parameter_objects) { [] }
  let(:aws_parameter_values) { [] }
  let(:aws_definition) do
    Aws::DataPipeline::Types::GetPipelineDefinitionOutput.new(
      pipeline_objects: aws_pipeline_objects,
      parameter_objects: aws_parameter_objects,
      parameter_values: aws_parameter_values)
  end

  describe '#unmarshal_pipeline_object' do
    let(:aws_pipeline_objects) do
      [
        Aws::DataPipeline::Types::PipelineObject.new(id: 'Id', name: 'Name', fields: [
          Aws::DataPipeline::Types::Field.new(key: 'type', string_value: 'Ec2Resource'),
          Aws::DataPipeline::Types::Field.new(key: 'subnetId', string_value: 'subnet'),
          Aws::DataPipeline::Types::Field.new(key: 'securityGroupIds', string_value: 'group1'),
          Aws::DataPipeline::Types::Field.new(key: 'securityGroupIds', string_value: 'group2')
        ])
      ]
    end

    it 'creates a object attribute string array when appropriate' do
      pipeline = subject.unmarshal(aws_definition)
      ec2_resource = pipeline.objects[:id]
      assert ec2_resource.subnet_id = 'subnet'
      assert ec2_resource.security_group_ids == ['group1', 'group2'], ec2_resource.security_group_ids.inspect
    end
  end 
   
  describe '#unmarshal_parameter_values' do
    let(:aws_parameter_values) do
      [
        Aws::DataPipeline::Types::ParameterValue.new(id: 'subnetId', string_value: 'subnet'),
        Aws::DataPipeline::Types::ParameterValue.new(id: 'securityGroups', string_value: 'group1'),
        Aws::DataPipeline::Types::ParameterValue.new(id: 'securityGroups', string_value: 'group2')
      ]
    end

    it 'creates a parameter value string array when appropriate' do
      pipeline = subject.unmarshal(aws_definition)
      assert pipeline.parameter_values['subnetId'] = 'subnet'
      assert pipeline.parameter_values['securityGroups'] = ['group1', 'group2']
    end
  end
end
