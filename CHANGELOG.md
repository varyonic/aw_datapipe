# CHANGELOG

## TODO
- Updating.
  - http://stackoverflow.com/questions/31188739/how-to-automate-the-updating-editing-of-amazon-data-pipeline
  - http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-manage-pipeline-modify-console.html
- Add Thor based utility instead of console for downloads.
- Generate separate SQL script files.
- Codecov.
- CodeClimate.
- Rubydocs.
- AWS labs examples converted to DSL.

## 0.3.1 - 2018-06-20
- Add tests and fix Pipeline#ec2_resource.

## 0.3.0 - 2018-06-14
- Use AWS SDK v3.
- Separate appending activities from initializing pipeline with config.
- Add helper methods to provide a more hierarchical builder API.
- Provide default settings for a pipeline EC2 resource.

## 0.2.4 - 2017-05-24
- Add ShellCommandActivity optional parameters.

## 0.2.3 - 2017-05-24
- Don’t include unpopulated optional fields when converting PipelineObject#to_hash.

## 0.2.2 - 2017-05-24
- Add CsvDataFormat.

## 0.2.1 - 2017-05-16
- Allow either S3 directory\_path or file\_path.
- Add ShellCommandActivity.

## 0.2.0 - 2017-05-06
- [FIX] Handle array values, e.g. 'securityGroups' => ['group1', 'group2']
- Separate SourceWriter class.
- Simplify build vs. new.
- Default id value based on pipeline object name.
- Unit tests, eg. PipelineSerializer.
- Travis.

## 0.1.0 - 2017-05-03
- Proof of concept: get and put pipeline definitions, marshal and unmarshal into ruby objects and generate working update script output.