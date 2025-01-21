#!/usr/bin/env cwl-runner
$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool#

cwlVersion: v1.2
$graph:
- class: Workflow
  id: preprocessing
  doc: Sentinel-1 image pre-processing with snappy
  inputs:
    use_case_directory:
      doc: directory where to find input files and where to store outputs
      type: Directory
    sentinel_list:
      doc: txt file containing sentinel data paths (output from application package 1)
      type: File
    verbose:
      doc: verbose
      type: boolean?
    debug:
      doc: debug
      type: boolean?

  outputs:
    preprocessing_output:
      type: Directory
      outputSource: preprocessing/results

  steps:
    preprocessing:
      in:
        use_case_directory: use_case_directory
        sentinel_list: sentinel_list
        verbose: verbose
        debug: debug
      run: '#preprocessing_tool'
      out:
      - results
      
- class: CommandLineTool
  id: preprocessing_tool
  label: "Pre-processing Tool"
  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)  
          writable: true 
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill002:2.0.0  
    - class: NetworkAccess
      networkAccess: true
   

  baseCommand:
      - /srv/miniconda3/envs/oilspill002/bin/python
      - -m
      - oilspill002.main
  inputs:
    use_case_directory:
      inputBinding:
        position: 1
        prefix: "--use-case-directory"
      type: Directory
    sentinel_list:
      inputBinding:
        position: 2
        prefix: "--sentinel_list"
      type: File
    verbose:
      inputBinding:
        position: 3
        prefix: "--verbose"
      type: boolean?
    debug:
      inputBinding:
        position: 4
        prefix: "--debug"
      type: boolean?

  outputs:
    results:
      type: Directory
      outputBinding:
        glob: $(inputs.use_case_directory.path)
  

  s:description: |-
    Pre-processing of SAR images from Sentinel-1
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