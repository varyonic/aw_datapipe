require 'test_helper'

describe AwDatapipe::SourceWriter do
  it 'writes source' do
    pipeline = AwDatapipe::Pipeline.new([AwDatapipe::Configuration.build(id: :default)], {}, {})
    source = AwDatapipe::SourceWriter.new(pipeline).source
    assert source.size > 1
  end
end
