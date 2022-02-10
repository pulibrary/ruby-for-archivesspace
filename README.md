# Ruby for ArchivesSpace
ArchivesSpace REST API tutorials for Ruby

## Prerequisites

- git
- Ruby (release 2.7.7 or later)
- Bundler (release 2.2.27 or later)

## Initializing the Environment

```bash
$ git clone https://github.com/pulibrary/aspace_helpers.git
$ bundle install
```

## REST API Tutorials

- Introduction to REST
- [httparty (HTTP client)](https://github.com/jnunemaker/httparty)

## ArchivesSpace API Tutorials

- [archivesspace-client (ArchivesSpace API client by Lyrasis)](https://github.com/lyrasis/archivesspace-client)
- Authentication
- Container Profiles
- Location Profiles
- Locations

### Repositories
- Repositories
- Top Containers
- Accessions
- Assessments

#### Resources
- Resources
- EAD representation of a Resource
- Get a PDF representation of a Resource
- Find Top Containers (and contained Archival Objects) linked to a given published Resource

#### Digital Objects
- Digital Objects
- Requesting Dublin Core Metadata
- Requesting METS Metadata
- Requesting MODS Metadata
- Find Digital Objects for any given `digital_object_id`
- Find Digital Object Components for any given `component_id`

#### Archival Objects
- Archival Objects
- Children of Archival Objects
- Tree Views of Records
- Find Archival Objects for any given `ref_id` or `component_id`

### Searching
- Searching across all repositories
- Searching within a specific repository
- Searching within a specific top containers

