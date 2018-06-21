require_relative 'pipeline_object'

module AwDatapipe

  class Ec2Resource < PipelineObject
    attr_accessor :action_on_task_failure, :instance_type, :security_group_ids, :subnet_id, :terminate_after

    def copy_activity(params)
      pipeline.append_object CopyActivity.build(params.merge(runs_on: self))
    end

    def shell_command_activity(params)
      pipeline.append_object ShellCommandActivity.build(params.merge(runs_on: self))
    end
  end

  class CopyActivity < PipelineObject
    attr_accessor :input, :output, :runs_on
  end

  class RedshiftCopyActivity < PipelineObject
    attr_accessor :input, :insert_mode, :output, :runs_on
  end

  class ShellCommandActivity < PipelineObject
    attr_accessor :input, :output, :runs_on, :command, :script_argument, :script_uri, :stage
  end
end
