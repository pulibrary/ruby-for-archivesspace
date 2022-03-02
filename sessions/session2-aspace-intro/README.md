# The aspace_helpers repository
This is the repository for ASpace-related data work, including reports and data-cleanup routines run on behalf of Special Collections.
https://github.com/pulibrary/aspace_helpers

NB: This repository is changing on a daily basis.

## helper_methods.rb
This file contains an evolving library of methods for things we need to do over and over.

To use the methods in a script, reference 

`require_relative 'helper_methods.rb'`

at the top of the file (make sure to adjust the path).

## usage_examples.rb
This file holds examples of how to use some of the helper methods in real life.

They can usually be re-purposed with minor modifications.

## authentication.rb
This file holds ASpace credentials necessary for the API authentication.

It is required by the helper_methods but is NOT in github for obvious reasons.

1. Create your own authentication.rb directly in aspace_helpers and populate it with the following code:

    ```
    @production = "https://aspace.princeton.edu/staff/api"
    @staging = "https://aspace-staging.princeton.edu/staff/api"
    @user = "your_user_name"
    @password = "your_password"
    ```
2. Add `authentication.rb` to your .gitignore file so it never gets pushed to github.

## Let's authenticate and get something back!
### test.rb
    ```
    require 'archivesspace/client'
    require_relative 'helper_methods.rb'

    client = aspace_login(@staging)
    repos = client.get('repositories')

    repos.parsed.each do |repo|
      puts repo['repo_code']
    end
    ```
    
Now let's get all resources in repo 12 with helper method `get_all_records_for_repo_endpoint`...
