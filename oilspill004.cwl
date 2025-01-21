#!/usr/bin/env cwl-runner

cwlVersion: v1.2  

$graph:
- class: Workflow
  id: segmentation
  doc: Global object detection model applied to Sentinel-1 images for oil spill identification (oilspill004 version)

  inputs:
    use_case_directory:
      doc: "Directory name for the use case, e.g., 'corsica'"
      type: Directory
    sentinel_list:
      doc: "TXT file containing paths of Sentinel-1 images"
      type: File
    png_output_path:
      doc: "Output path for pre-processed PNG files"
      type: File
    csv_output_path:
      doc: "Output path for CSV files of bounding boxes"
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
    segmentation_output:
      type: Directory
      outputSource: segmentation/results

  steps:
    segmentation:
      in:
        use_case_directory: use_case_directory
        sentinel_list: sentinel_list
        png_output_path: png_output_path
        csv_output_path: csv_output_path
        delete: delete
        verbose: verbose
        debug: debug
      run: '#segmentation_tool'
      out: 
        - results

- class: CommandLineTool
  id: segmentation_tool
  label: "Segmentation Tool (oilspill004)"
  requirements:
    - class: InitialWorkDirRequirement
      listing:
        - entryname: $(inputs.use_case_directory.basename)  
          writable: true 
          entry: $(inputs.use_case_directory)
    - class: DockerRequirement
      dockerPull: registry.services.meeo.it/outmani/iliad_oil_spill_pilot/oilspill004:1.0.0  # Use the same image for this tool if needed
    - class: NetworkAccess
      networkAccess: true
    - class: InlineJavascriptRequirement
  
  baseCommand: 
    - /srv/miniconda3/envs/oilspill004/bin/python  # Specify the correct Python executable path
    - -m
    - oilspill004.main  # Update the module path if necessary
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
    delete:
      type: boolean?
      inputBinding:
        position: 5
        prefix: "--delete"
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
s:name: Sentinel-1 Oil Spill Detection Pipeline (oilspill004)
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
