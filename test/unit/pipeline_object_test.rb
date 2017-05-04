require 'test_helper'

describe AwDatapipe::PipelineObject do
  let(:s3_path) { AwDatapipe::S3DataNode.build(id: :s3_path, name: 'S3', directory_path: '/tmp') }

  describe '#to_hash' do
    it 'includes :id and :name' do
      assert s3_path.to_hash == { id: :s3_path, name: 'S3', directory_path: '/tmp' }, s3_path.inspect
    end
  end
end
