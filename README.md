# brutalkeychain
Recover lost keychain passwords using a simple swift script (so can run natively on Mac or compile and be used in other tools).

## V2
Download the compiled binary or the Xcode Project (e.g. to tweak the logic). The binary has the -l (integer of length), -n (name of keychain), and -p (patterns like "tes 123") options as follows:

`./BruteforceKeychain -l 8 -n login.keychain-db`

The above would test a locked login keychain for all possible 8 character combinations.

## V1
The first version of this script is really written to just be run in xcode. 

`Enter name or path of the keychain to crack:`
`>>> `
`test.keychain`

`Enter the parts of the password you can remember.`
`Replace the characters you can't remember with spaces.`
`Just press enter if can't remember anything:`
`>>> tes 123`

`How long is the password?`
`>>>` 
`7`

Then it just loops through and tries each combination of characters, working around those that are missing. The above example is only missing one character but leave that field blank and it would start with aaaaaaa and loop through until the process is stopped.

## Notes
The core of the script is really this line:

` let result = runCommand(cmd: "/usr/bin/security", args: "unlock-keychain", "-p", key, keychain)`

Leveraging the native keychain APIs in swift would be more efficient and provide more options from a runtime perspective. For example, the keychain must be locked or the script will error out. That could be fixed by shelling out a quick function that uses this instead but was outside this scope (PRs accepted):

` let result = runCommand(cmd: "/usr/bin/security", args: "lock-keychain" keychain)`

But this suits the needs at hand. Changing the runCommand structure though, could be used to fix future bugs introduced by breaking changes to the security binary or even swap out to other commands to port to other tools (e.g. curl for websites/JWTs/whatevers). Also should probably compile it and make operators for -keychain -length and -patterns so it can run outside of xcode. And add a sanity check to see if the keychain is unlocked before just erroring out. Or not...

## Attribution
V1 used the Ruby script at https://github.com/peterhil/keychainrecovery for the structure and a few ideas to speed up recovery (like allowing for entering parts of the password that are known) but wanted to run natively in swift. 
