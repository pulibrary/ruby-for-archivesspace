## Review: Get uri, cid, and title for all archival objects in Graphic Arts
- edit `authentication.rb` to point at staging
- edit the aspace_login method in test.rb to use the staging credentials
- use helper_methods `get_all_records_for_repo_endpoint`
- East Asian > repo 12, Graphic Arts > repo 11
- endpoint: https://archivesspace.github.io/archivesspace/api/?shell#create-an-archival-object
```
require 'archivesspace/client'
require_relative 'helper_methods.rb'

#log in
aspace_login(@staging)

#define archival objects
aos = get_all_records_for_repo_endpoint(12, 'archival_objects')

#print select ao fields to screen
aos.map { |ao| puts "#{ao['uri']}, #{ao['ref_id']}, #{ao['title']}" }
```

## Using aspace_helper reports
https://github.com/pulibrary/aspace_helpers/tree/main/reports/plain_vanilla_report_templates

### Read-through
https://github.com/pulibrary/aspace_helpers/blob/main/reports/plain_vanilla_report_templates/containers_and_restrictions.rb

### Adapting containers_and_restrictions.rb
- give the login method an argument
- eadid = "EA01"
- resource_ids = [1467]
- repo = 12

- second pass: comment in the bit to exclude the collection-level: `ao_uris << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'`

Further practice:
- [ ] How do I output to CSV only, not to stdtout?
- [ ] How do I remove a column from the CSV output?
- [ ] How do I output to stdtout only, not to CSV?
- [ ] How do I remove a column from the stdtout output?
