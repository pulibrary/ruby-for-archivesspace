# Ruby for ArchivesSpace
Workshop for operations against the ArchivesSpace REST API using Ruby

## Getting Started

### Google Cloud Shell
[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/pulibrary/ruby-for-archivesspace.git)

#### Initializing the Environment
```bash
$ bin/init
```

#### Resetting the Environment
Should any repository files be corrupted, or should there be bugs arising from the state of the repository source code files, one may reset the state of the environment with the following:

```bash
$ bin/reset
```

### Princeton University Library Infrastructure

Please see [the Princeton University Library Infrastructure page](./PULIBRARY_INFRA.md) for instructions on accessing the server environment `ruby-office1.princeton.edu`.

## Workshop Sessions

### Session 1 (REST API Tutorials)
[_Recording on Zoom Cloud from 02/24/2022_](https://princeton.zoom.us/rec/share/Ltrg9-gEqVjEpcN9UIhV6oS7ZJHq3AySuSaFzyuY7_CnqIGx9gFonGTKjIPSwzr5.-BI7QH9u1iKMcGVZ)

- Introduction to REST
- [httparty (HTTP client)](https://github.com/jnunemaker/httparty)
- [archivesspace-client (ArchivesSpace API client by Lyrasis)](https://github.com/lyrasis/archivesspace-client)
- Authentication for ArchivesSpace

### Session 2 (Introduction to the ArchivesSpace API)
[_Recording on Zoom Cloud from 03/03/2022_](https://princeton.zoom.us/rec/share/iT0sM8nVSxQbxSZvA__beSMkvnhxD49UlbAXBI-H3lcMgUiLk0txf5u2OPRPv7s.3JlSOeEKXtJegzVq)

- Overview of aspace_helpers
- Methods in helper_methods.rb
- Examples in usage_examples.rb
- Authenticate with authentication.rb
- Our first script

### Session 3 (Batch Operations with the ArchivesSpace API)
- Loops
- Arrays and Hashes in ArchivesSpace
- Gotchas

