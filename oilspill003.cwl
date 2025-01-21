#!/usr/bin/env cwl-runner
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

cwlVersion: v1.2
$graph:
- class: Workflow
  id: objectdetection
  doc: global object detection machine learning model applied to Sentinel-1 images for oil spill identification
    

  inputs:
    use_case_directory:
      doc: "directory where to find input files and where to store outputs"
      type: Directory
    db_list:
      doc: "txt file containing paths of preprocessed sentinel-1 images"
      type: File
    range:
      doc: "range 0-100 for image contrast enhancement"
      type: string?
    verbose:
      doc: "verbose"
      type: boolean? 
    debug:
      doc: "debug"
      type: boolean?  

  outputs:
    objectdetection_output:
      type: Directory
      outputSource: object_detection/results

  steps:
    object_detection:
      in:
        use_case_directory: use_case_directory
        db_list: db_list
        range: range
        verbose: verbose
        debug: debug
      run: '#objectdetection_tool'
      out:
        - results

- class: CommandLineTool
  id: objectdetection_tool
  label: "Object Detection Tool"
  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)  
          writable: true 
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill003:1.0.0  # Use the same image for this tool if needed
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement
  baseCommand: 
    - /srv/miniconda3/envs/oilspill003/bin/python  # Path to your Python executable
    - -m
    - oilspill003.main  # Path to your script
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
    range:
      type: string?  # Correctly formatted as an array of strings or null for optional
      inputBinding:
        position: 4
        prefix: "--r"
    verbose:
      type: boolean?  # Correctly formatted as boolean or null for optional
      inputBinding:
        position: 5
        prefix: "--verbose"
    debug:
      type: boolean? # Correctly formatted as boolean or null for optional
      inputBinding:
        position: 6
        prefix: "--debug"

  outputs:
    results:
      type: Directory
      outputBinding:
        glob: $(inputs.use_case_directory.path)
  

s:description: |-
  Machine learning model designed for detecting oil spill signals globally from SAR images from Sentinel-1.
s:name: Sentinel-1 Oil Spill Detection Pipeline
s:softwareVersion: 1.0.0
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

