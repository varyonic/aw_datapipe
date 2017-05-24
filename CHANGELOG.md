# CHANGELOG

## TODO
- Updating.
  - http://stackoverflow.com/questions/31188739/how-to-automate-the-updating-editing-of-amazon-data-pipeline
  - http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-manage-pipeline-modify-console.html
- Add DSL using clean room.
- Add Thor based utility instead of console for downloads.
- Generate separate SQL script files.
- Codecov.
- CodeClimate.
- Rubydocs.
- AWS labs examples converted to DSL.

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