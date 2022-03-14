## Looping over an array
### Get information for each item in an array
We can get all repository records out in one big array of hashes. But how do we get just certain fields?
### Wait. What's an array, what's a hash?
- An array is basically a list of discrete items. The list is in square brackets. The items in an array can be various data types, e.g. strings, integers, nested arrays, hashes, or even a combination. 
    - This is an array of strings. Strings are always in quotes.
    `["Will", "Valencia", "Phoebe"]`
    - This is an array of integers. Integers are not in quotes.
    `[1,2,3,4]`
    - This is an array of arrays. You may encounter an array of arrays e.g. when you add the returns of a loop to an array, and each loop itself already returned an array.
    `[[1,2,3], [45, 72], ["a", "b"]]`
- A hash is a list of key-value pairs. The list is in curly braces. The key is in quotes to the left of the rocket operator, the value is to the right. The value can be various data types, e.g. strings, integers, or arrays.
    - This is a k/v pair with a string for a value: `"username"=>"mudd"`
    - This is a k/v pair with a boolean for a value: `"is_system_user"=>false`
    - This is a k/v pair with an (empty) array for a value: `"instances"=>[]`
    - This is a k/v pair with an array of (2) hashes for a value:
    ```    
    "notes"=>[{"jsonmodel_type"=>"note_singlepart",
    "persistent_id"=>"203a94dca71fac04059f83fc5b9b3d72",
    "type"=>"abstract",
    "content"=>["This collection contains over 600 sets of student notes taken from lectures given by members of Princeton's faculty. They represent the broad range of courses taught at Princeton University (known as the College of New Jersey prior to 1896) and include the works of numerous famous faculty and students."]
    "publish"=>true}
    {"jsonmodel_type"=>"note_singlepart",
    "persistent_id"=>"d16a96d4b221ee8534f1c7ccf43a4a6d",
    "type"=>"physloc",
    "content"=>["mudd"]
    "publish"=>true}
    ```

To get at single ASpace record out of an array of records, we need to create a loop. A loop means we take each item in the array in turn and do something with it.

### Review: Get all repository records out at once.
#### Ruby reminders:
- `.class` tells you what type of object something is. 
- `.each` iterates over an array and returns the array (unless you specify a different return)
- `.map` iterates over an array and returns the results of the iteration
- `.select` creates a result set based on a filter

Let's get all repository record out again:
```
require 'archivesspace/client'
require_relative 'helper_methods.rb'

#log in
client = aspace_login(@sandbox)
#define repositories
repos = client.get('repositories')

#do something with the response
puts repos.parsed
```

Let's examine the response using `.class`:
```
#do something with the response
puts repos.parsed.class
```
For kicks, let's examine the response before parsing the response object:
```
#do something with the response
puts repos.class
```
## Loop over an array: `.each` and `.map`


Let's iterate over the parsed response using `.each`:
```
#do something with the response
repos.parsed.each do |repo|
    puts repo
end
```
Check what type of object `repo` is, using `.class`

Let's iterate over the parsed response using `.map`:
```
#do something with the response
repos.parsed.map |repo|
    puts repo
end
```
Check what type of object `repo` is, using `.class`

## Interlude: Getting the value of a key/value pair
You can return the value of a key/value pair by referencing the key. This is done by placing it in square brackets.

Here, we loop over an array of hashes and, for each hash, get out the value of the `name` field:
```
#do something with the response
repos.parsed.each do |repo|
    puts repo['name']
end
```

## Loop over an array: `.each` v. `map `

`.each` and `.map` may look the same to you so far. That's because we're forcing an immediate output for each loop. Observe what happens if we return the array after the loops have run. FYI both these methods have a long and a short syntax; I'm exemplifying both here:

`.map` long syntax:
```
#do something with the response
names = repos.parsed.map do |repo| 
    repo['name']
end
puts names
```
`.map` short syntax:
```
#do something with the response
names = repos.parsed.each { |repo| repo['name']}
puts names
```
Check what type of object `names` is, using `.class`

`.each` long syntax:
```
#do something with the response
names = repos.parsed.each do |repo| 
    repo['name']
end
puts names
```
`.each` short syntax:
```
#do something with the response
names = repos.parsed.map { |repo| repo['name']}
puts names
```
Check what type of object `names` is, using `.class`

## Get the value of a key/value pair that is itself the value of a key/value pair
What if we want to get the uri of the agent associated with a repository?

`"agent_representation"=>{"ref"=>"/agents/corporate_entities/7"}}`
We can do that by referencing the key in square brackets:

```
#do something with the response
uris = repos.parsed.map do |repo| 
    repo['agent_representation']['ref']
end
puts uris
```
Try doing the same using the short syntax.

## Return only certain records
Let's say we only want to see the names of the repositories that are published.

A `.select` loop allows us to filter on the value of the key/value pair and return only those that match. 

NB: `.select`, like `.each`, returns the original array, so be sure to return output inside the loop.

```
#do something with the response
names = repos.parsed.select do |repo| 
    puts repo['name'] unless repo['publish']==false
end

```
