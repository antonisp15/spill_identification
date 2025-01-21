#!/usr/bin/env cwl-runner
  
cwlVersion: v1.2  

$graph:
- class: Workflow
  id: snappy_extraction
  doc: Global object detection model applied to Sentinel-1 images for oil spill identification (oilspill005 version)
  
  inputs:
    use_case_directory:
      doc: "Directory name for the use case, e.g., 'corsica'"
      type: Directory
    sentinel_list:
      doc: "TXT file containing paths of Sentinel-1 images"
      type: File
    csv_paths:
      doc: "Output txt with path for CSV files of bounding boxes"
      type: File 
    delete:
      doc: "Enable verbose mode for detailed logging"
      type: boolean?  
    verbose:
      doc: "Flag to delete auxiliary files"
      type: boolean?  
    debug:
      doc: "Enable debug mode for additional troubleshooting"
      type: boolean?

  outputs:
    snappy_extraction_output:
      type: Directory
      outputSource: snappy_extraction/results
  
  steps:
    snappy_extraction:
      in:
        use_case_directory: use_case_directory
        sentinel_list: sentinel_list
        csv_paths: csv_paths
        delete: delete
        verbose: verbose
        debug: debug
      run: '#snappy_extraction_tool'
      out: 
        - results
- class: CommandLineTool
  id: snappy_extraction_tool
  label: "Snappy Extraction Tool (oilspill005)"
  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)  
          writable: true 
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill005:1.0.0  # Use the same image for this tool if needed
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement

  baseCommand: 
    - /srv/miniconda3/envs/oilspill005/bin/python  # Specify the correct Python executable path
    - -m
    - oilspill005.main  # Update the module path if necessary
 
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
    csv_paths:
      inputBinding:
        position: 3
        prefix: "--csv_paths"
      type: File
    delete:
      type: boolean?
      inputBinding:
        position: 4
        prefix: "--delete"
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