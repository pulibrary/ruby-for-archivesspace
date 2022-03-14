## Looping over an array
### Get information for each item in an array
We can get all resource records out in one big array of hashes. But how do we get just certain fields?
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

### Nested arrays (and how to flatten them)

## Accessing a Hash

### Looking for a field that may not exist
### Looking for a field that may be nil
