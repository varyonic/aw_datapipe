require 'test_helper'

describe AwDatapipe::Session do
  it 'download_definition' do
    pipelines = AwDatapipe::Session.new
    assert pipelines != nil

    assert pipelines.keys.is_a?(Array)

    pipeline = pipelines.fetch(pipelines.keys.first)

    assert pipeline.parameter_values.is_a?(Hash)
    assert pipeline.parameter_metadata.is_a?(Hash)
    assert pipeline.objects.is_a?(Hash)

    pipelines.download_definition(pipelines.keys.first, 'tmp/pipeline-definition.rb')
  end
end
