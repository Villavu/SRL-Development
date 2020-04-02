SRL uses semantic versioning for all it's releases.
https://semver.org/

This means that we have 3 values for our versions: **MAJOR**, **MINOR** and **PATCH**

In short
----------
* a **MAJOR** bump means that there has been breaking changes, changes that may break scripts.
  like removing a function, renaming a function, changing the API for some interface and such.
  
* a **MINOR** bump means we have added new functionallity or rewrote exiting functionallity 
  without breaking the API, so no scripts should break.
  
* a **PATCH** bump is done whenever a bug is found in some existing functionallity, or that RS
  updated so we have to adjust/tweak/fix existing functionallity to work out the issue - without breaking the API.

  
Now you can still fix bugs, while adding new functionallity without doing a release just yet, if this is done it would 
just bump the **MINOR**.. Since adding new functionallity causes **MINOR** bump, which will by default reset the **PATCH**, see further down

*Note: Internally in SRL there is a VERSION define, it should be updated with new releases its located in `osr.simba` (the main include file)*
https://github.com/SRL/SRL/blob/master/osr.simba#9


Examples
----------
### Bumpung the *MAJOR*:
The **MAJOR** should **only** be bumped when you break the API, and this should be thought through so that API 
changes doesn't happen too often, when you first break something you probably also should have thought about it 
so that if there is anything else you'd need to change, do so now.
Bumping the **MAJOR** resets both **MINOR** and **PATCH** to zero. So going from version *2.6.3* puts you at *3.0.0*.

### Bumpung the *MINOR*:
Say we are at version *1.1.5*, and we add some new functions to the include, without breaking backwards 
compatibility and we make a release we'd want to bump the **MINOR**, bumping the minor will cause the 
**PATCH** to reset. So our version is now *1.2.0*.

### Bumpung the *PATCH*:
So we are at version *1.2.0* currently, but RS updated, they changed the minimap coordinates slightly,
to fix this we need to shift the coordinates slightly, this is a prime case for a **PATCH**, and doing so
puts us at version *1.2.1*.

----------


There is no limit to the number of **PATCH** or **MINOR** increments made:

* **MINOR**: `1.5.0`, `1.6.0`, `1.7.0` ... `1.10.0`, `1.11.0` ... `1.37.0`, `1.38.0` ...

* **PATCH**: `1.0.1`, `1.0.2`, `1.0.3` ... `1.0.12`, `1.0.13` ... `1.0.22`, `1.0.23` ...


