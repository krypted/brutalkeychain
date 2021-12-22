# keychainbrute
## Recover lost keychain passwords using a simple swift script (so can run natively on Mac or compile and be used in other tools).

Note that the core of the script is really this line:

` let result = runCommand(cmd: "/usr/bin/security", args: "unlock-keychain", "-p", key, keychain)`

Leveraging the native keychain APIs in swift would be more efficient and provide more options from a runtime perspective. For example, the keychain must be locked or the script will error out. That could be fixed by shelling out a quick function that uses this instead but was outside this scope (PRs accepted):

` let result = runCommand(cmd: "/usr/bin/security", args: "lock-keychain" keychain)`

But this suits the needs at hand. Changing the runCommand structure though, could be used to fix future bugs introduced by breaking changes to the security binary or even swap out to other commands to port to other tools (e.g. curl for websites/JWTs/whatevers). 

Used the Ruby script at https://github.com/peterhil/keychainrecovery for the structure and a few ideas to speed up recovery (like allowing for entering parts of the password that are known) but this is in swift. 
