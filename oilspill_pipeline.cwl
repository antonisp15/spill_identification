#!/usr/bin/env cwl-runner

cwlVersion: v1.2

$graph:
  - class: Workflow
    id: oilspill_pipeline
    doc: Oil Spill Detection and Analysis Pipeline 1-2-3-4

    inputs:
      use_case_directory:
        doc: Path to directory as a string where to find input files and where to store outputs
        type: string
      bbox:
        doc: Bounding box for image search
        type: string?
      start_date:
        doc: Start date for data search
        type: string?
      time_interval:
        doc: Time interval (n of days) for data search
        type: int?
      end_date:
        doc: End date for data search
        type: string?
      verbose:
        doc: Enable verbose logging
        type: boolean?
      debug:
        doc: Enable debug mode
        type: boolean?
      asf_username:
        type: string
      asf_password:
        type: string

    outputs:
      pipeline_output:
        type: Directory
        outputSource: step_segmentation/results

    steps:
      step_data_search:
        in:
          bbox: bbox
          use_case_directory: use_case_directory
          start_date: start_date
          time_interval: time_interval
          end_date: end_date
          verbose: verbose
          debug: debug
          asf_username: asf_username
          asf_password: asf_password
        run: "#datasearch_tool"
        out:
          - results
          - sentinel_list

      step_preprocessing:
        in:
          use_case_directory: step_data_search/results
          sentinel_list: step_data_search/sentinel_list  
          verbose: verbose
          debug: debug
        run: "#preprocessing_tool"
        out:
          - results
          - db_list

      step_object_detection:
        in:
          use_case_directory: step_preprocessing/results
          db_list: step_preprocessing/db_list
          verbose: verbose
          debug: debug
        run: "#objectdetection_tool"
        out:
          - results
          - png_output_path
          - csv_output_path

      step_segmentation:
        in:
          use_case_directory: step_object_detection/results
          sentinel_list: step_data_search/sentinel_list  
          png_output_path: step_object_detection/png_output_path
          csv_output_path: step_object_detection/csv_output_path
          verbose: verbose
          debug: debug
        run: "#segmentation_tool"
        out:
          - results

  - class: CommandLineTool
    id: datasearch_tool
    label: Data Search Tool
    requirements:
      - class: DockerRequirement
        dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill001:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement

    baseCommand:
      - /srv/miniconda3/envs/oilspill001/bin/python
      - -m
      - oilspill001.main
    inputs:
      bbox:
        type: string?
        inputBinding:
          position: 1
          prefix: "--bbox"
      use_case_directory:
        type: string
        inputBinding:
          position: 2
          prefix: "--dir"
      start_date:
        type: string?
        inputBinding:
          position: 3
          prefix: "--start"
      time_interval:
        type: int?
        inputBinding:
          position: 4
          prefix: "--days"
      end_date:
        type: string?
        inputBinding:
          position: 5
          prefix: "--end"
      verbose:
        type: boolean?
        inputBinding:
          position: 6
          prefix: "--verbose"
      debug:
        type: boolean?
        inputBinding:
          position: 7
          prefix: "--debug"
      asf_username:
        type: string
        inputBinding:
          position: 8
          prefix: "--asf-username"
      asf_password:
        type: string
        inputBinding:
          position: 9
          prefix: "--asf-password"

    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory)
      sentinel_list:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory)/raw_sentinel/sentinel_paths.txt

  - class: CommandLineTool
    id: preprocessing_tool
    label: Pre-processing Tool
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill002:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement

    baseCommand:
      - /srv/miniconda3/envs/oilspill002/bin/python
      - -m
      - oilspill002.main
    inputs:
      use_case_directory:
        type: Directory
        inputBinding:
          position: 1
          prefix: "--use-case-directory"
      sentinel_list:
        type: File
        inputBinding:
          position: 2
          prefix: "--sentinel_list"
      verbose:
        type: boolean?
        inputBinding:
          position: 3
          prefix: "--verbose"
      debug:
        type: boolean?
        inputBinding:
          position: 4
          prefix: "--debug"

    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory.path)
      db_list:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/db_paths.txt

  - class: CommandLineTool
    id: objectdetection_tool
    label: Object Detection Tool
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill003:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement

    baseCommand:
      - /srv/miniconda3/envs/oilspill003/bin/python
      - -m
      - oilspill003.main
    inputs:
      use_case_directory:
        type: Directory
        inputBinding:
          position: 1
          prefix: "--dir"
      db_list:
        type: File
        inputBinding:
          position: 2
          prefix: "--db"
      verbose:
        type: boolean?
        inputBinding:
          position: 3
          prefix: "--verbose"
      debug:
        type: boolean?
        inputBinding:
          position: 4
          prefix: "--debug"

    outputs:
      results:
          type: Directory
          outputBinding:
            glob: $(inputs.use_case_directory.path)
      png_output_path:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/png_paths.txt
      csv_output_path:
        type: File
        outputBinding:
          glob: $(inputs.use_case_directory.path)/intermediate_dir/csv_paths.txt

  - class: CommandLineTool
    id: segmentation_tool
    label: Segmentation Tool
    requirements:
      - class: InitialWorkDirRequirement
        listing:
          - entryname: $(inputs.use_case_directory.basename)
            entry: $(inputs.use_case_directory)
            writable: true
      - class: DockerRequirement
        dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill004:1.0.0
      - class: NetworkAccess
        networkAccess: true
      - class: InlineJavascriptRequirement

    baseCommand:
      - /srv/miniconda3/envs/oilspill004/bin/python
      - -m
      - oilspill004.main
    inputs:
      use_case_directory:
        type: Directory
        inputBinding:
          position: 1
          prefix: "--use-case-directory"
      sentinel_list:
        type: File
        inputBinding:
          position: 2
          prefix: "--sentinel-list"
      png_output_path:
        type: File
        inputBinding:
          position: 3
          prefix: "--png-output-path"
      csv_output_path:
        type: File
        inputBinding:
          position: 4
          prefix: "--csv-output-path"
      verbose:
        type: boolean?
        inputBinding:
          position: 5
          prefix: "--verbose"
      debug:
        type: boolean?
        inputBinding:
          position: 6
          prefix: "--debug"

    outputs:
      results:
        type: Directory
        outputBinding:
          glob: $(inputs.use_case_directory.path)

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool

s:description: |
  Machine learning model for detecting oil spills in Sentinel-1 SAR images.
s:name: Sentinel-1 Oil Spill Detection Pipeline (oilspill005)
s:softwareVersion: 2.0.0
s:programmingLanguage: python
s:sourceOrganization:
  - class: s:Organization
    s:name: MEEO SRL
    s:url: https://meeo.it/
  - class: s:Organization
    s:name: FORTH
    s:url: https://www.forth.gr/
  - class: s:Organization
    s:name: INESCTEC
    s:url: https://inesctec.pt
s:author:
  - class: s:Person
    s:email: outmani@meeo.it
    s:name: Sabrina Outmani
  - class: s:Person
    s:email: fazzini@meeo.it
    s:name: Noemi Fazzini