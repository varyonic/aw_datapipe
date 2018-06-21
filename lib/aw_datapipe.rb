require 'active_support/core_ext/module/delegation'
require 'active_support/inflector' # String#underscore
require 'aws-sdk-datapipeline'

require 'aw_datapipe/parameter_metadata'
require 'aw_datapipe/pipeline'
require 'aw_datapipe/database'
require 'aw_datapipe/ec2_resource'
require 'aw_datapipe/pipeline_serializer'
require 'aw_datapipe/object_hash'
require 'aw_datapipe/session'
require 'aw_datapipe/source_writer'
require 'aw_datapipe/version'
