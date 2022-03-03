# Lyrasis API documentation
Your guide to available endpoints, routes, and behaviors of the API: https://archivesspace.github.io/archivesspace/api/

# The PUL aspace_helpers repository
This is the repository for ASpace-related data work, including reports and data-cleanup routines run on behalf of Special Collections.
https://github.com/pulibrary/aspace_helpers

NB: This repository is changing on a daily basis.

## helper_methods.rb
This file contains an evolving library of methods for things we need to do over and over.

To use the methods in a script, reference 
```
    require_relative 'helper_methods.rb'
```
at the top of the file (make sure to adjust the path).

## usage_examples.rb
This file holds examples of how to use some of the helper methods in real life.

They can usually be re-purposed with minor modifications.

## authentication.rb
This file holds ASpace credentials necessary for the API authentication.

It is required by the helper_methods but is NOT in github for obvious reasons.

1. Create your own authentication.rb directly in aspace_helpers and populate it with the following code:

```
    @sandbox = "https://sandbox.archivesspace.org/staff/api/"
    #@production = "https://aspace.princeton.edu/staff/api"
    #@staging = "https://aspace-staging.princeton.edu/staff/api"
    #change user/pw once you switch from the sandbox to staging or prod:
    @user = "admin"
    @password = "admin"
```
2. Optional: add `authentication.rb` to your .gitignore file so it never gets pushed to github.

## Let's authenticate and get something back!
### create test.rb
```
    require 'archivesspace/client'
    require_relative 'helper_methods.rb'

    #log in
    client = aspace_login(@sandbox)
    #define repositories
    repos = client.get('repositories')
    
    #do something with the response
```

### A few Ruby reminders:

- `puts` --> write output to terminal

- `.parsed` --> unpack a return object

- `repos.parsed[0]` --> index, a way of getting the n-th item in an array

- `"string #{variable}"` --> interpolation, a way to interpret a variable inside a string

--> run with `ruby test.rb`

### Excercises:

- return all repositories

  `puts repos.parsed`
- return the first repository

    `puts repos.parsed[0]`
- return the name of the repository

    `puts repos.parsed[0]['name']`
- return the uri of the repository

    `puts repos.parsed[0]['uri']`
- return the name and uri of the repository (use interpolation)

    `puts "This repository is called '#{repos.parsed[0]['name']}' and can be found at: #{repos.parsed[0]['uri']}"`

- get all resources in repo 2
    - endpoint: https://archivesspace.github.io/archivesspace/api/#get-a-list-of-resources-for-a-repository
    - helper method: `get_all_records_for_repo_endpoint` (this method paginates and parses the response)

```
    resources = get_all_records_for_repo_endpoint(2, 'resources')
    puts resources
```

- get a count of resources in repo 2

    `puts resources.count`
- get the first resource in repo 2
- get the second resource in repo 2
- get the last resource in repo 2

    hint: use `[-1]` or `.last`
- return a single field (e.g. 'title') for the first resource in repo 2
- return two or more fields (e.g. 'title' and 'uri') for the first resource in repo 2

## Practice
Get all archival objects for the Andrei Matei COVID-19 Quarantine Photographs

Hint: the collection is in the sandbox in repository 2

Some questions to ask in solving this:
- What's the endpoint for archival objects?
- Is there a helper method? If yes, what does it require as input?
- Can I query for the input needed for the helper method with what I know?
