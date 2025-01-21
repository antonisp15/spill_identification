cwlVersion: v1.2

$namespaces:
  s: https://schema.org/
  cwltool: http://commonwl.org/cwltool

$graph:
- class: Workflow
  id: datasearch

  inputs:
    use_case_directory:
      doc: Directory where to find input files and store outputs
      type: string
    bbox:
      doc: Bounding box for image search
      type: string?  # Optional
    start_date:
      doc: Start date for data search
      type: string?  # Optional
    time_interval:
      doc: Time interval (n of days) for data search
      type: int?  # Optional
    end_date:
      doc: End date for data search
      type: string?  # Optional
    verbose:
      doc: Enable verbose logging
      type: boolean?  # Optional
    debug:
      doc: Enable debug mode
      type: boolean?  # Optional
    asf_username:
      doc: Username for ASF
      type: string
    asf_password:
      doc: Password for ASF
      type: string

  steps:
    data_search:
      in:
        use_case_directory: use_case_directory
        bbox: bbox
        start_date: start_date
        time_interval: time_interval
        end_date: end_date
        verbose: verbose
        debug: debug
        asf_username: asf_username
        asf_password: asf_password
      run: '#datasearch_tool'
      out:
        - results

  outputs:
    datasearch_output:
      type: Directory
      outputSource: data_search/results

  s:softwareVersion: 1.0.0
  s:name: Sentinel-1 Oil Spill Detection Pipeline
  s:description: ASF search for SAR images from Sentinel-1
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
  s:dateCreated: "2024-12-01"

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
      type: string?  # Optional
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
        glob: "$(inputs.use_case_directory)/*"