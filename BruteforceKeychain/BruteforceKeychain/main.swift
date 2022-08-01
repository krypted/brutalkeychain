import Foundation

public class Bruteforce {
    static let prompt = ">>> "

    func getKeychain() -> String {
        
        print("Enter name or path of the keychain to crack:\n" + Bruteforce.prompt)
        var keychain = readLine()
        
        let pattern = "/^[^\\/].+$/"
        
        if keychain?.range(of: pattern, options: .regularExpression) != nil {
            keychain = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Keychains/" + keychain!
        }
              
        return keychain ?? ""
    }

    func getTemplate() -> String {
        
        print("Enter the parts of the password you can remember.")
        print("Replace the characters you can't remember with spaces.")
        print("Just press enter if can't remember anything:\n" + Bruteforce.prompt)
        var template = readLine()
        var keylength = template?.filter { $0 == " " }.count ?? 0
        
        // Can't remember any characters, use a blank template of certain length
        if template == "" {
          let defKeylength = 8
            print("How long was the password? [#{defKeylength}]\n" + Bruteforce.prompt)
            keylength = Int(readLine() ?? "0")!
            if keylength == 0 {
                keylength = defKeylength
            }
            template = String(repeating: " ", count: keylength)
        }

        //No holes (spaces) in template so exit
        if template?.firstIndex(of: " ") == nil {
          print("Nothing to do. Quitting.")
          exit(0)
        }

        return template!
    }

    func splitTemplate(template: String) -> Array<String> {
        return template.components(separatedBy: " ")
    }

    func merge(template: String, key: String) -> String {
        //Fills the spaces in the template from characters in the key
        let keyChars = key.components(separatedBy: "")
        
        let parts = splitTemplate(template: template)
        var merged = parts[0]
        for (index, element) in keyChars.enumerated() {
            merged += element + parts[index + 1]
        }
        
        return merged
    }
    
    func unlockKeychain(key: String, keychain: String) -> (output: [String], error: [String], exitCode: Int32) {
        
        let result = runCommand(cmd: "/usr/bin/security", args: "unlock-keychain", "-p", key, keychain)
        return result
    }
    
    func trypass(key: String, keychain: String) -> Bool {
        print(key + "\t")
        let result = unlockKeychain(key: key, keychain: keychain)
        
        switch result.exitCode {
            case 13056, 51: // Wrong     passphrase
                print("Wrong!")
                return false
            case 0:
                print("Bingo! The correct password is: " + key)
                print("Congratulations!")
                return true
            case 12800, 50:
                print("Error \(result.exitCode): The specified keychain could not be found. Quitting.")
                exit(result.exitCode)
            case 32256:
            print("Error \(result.exitCode): Permission denied. Quitting.")
                exit(result.exitCode)
            case 32512:
                print("Error \(result.exitCode): No such file or directory. Quitting.")
                exit(result.exitCode)
            default:
            print("\(result.exitCode) \(result.error)")
                exit(result.exitCode)
        }
    }
    
    func bruteforce(template: String, keychain: String) {
        let keylength = template.filter { $0 == " " }.count
        var key = String(repeating: "a", count: keylength)
        var success = false
        
        while success == false && key.count == keylength {
            let guess = merge(template: template, key: key)
            success = trypass(key: guess, keychain: keychain)
            key = succ(value: key)
        }
    }
    
    func succ(value: String) -> String {
        let alphabet = Array<Character>(" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!");
        var values: Array<Character> = Array<Character>(" " + value)
        var addone: Bool = true;

        for (index, _) in values.enumerated().reversed() {
            if addone
            {
                if (values[index] != "!")
                {
                    values[index] = alphabet[alphabet.firstIndex(of: values[index])! + 1]
                    addone = false;
                }
                else {
                    values[index] = "a"
                }
            }
        }

        return String(values).trimmingCharacters(in: .whitespaces)
    }
    
    func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {

        var output : [String] = []
        var error : [String] = []

        let task = Process()
        task.launchPath = cmd
        task.arguments = args

        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe

        try! task.run()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
            try! outpipe.fileHandleForReading.close()
        }

        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
            try! errpipe.fileHandleForReading.close()
        }
        task.waitUntilExit()
        let status = task.terminationStatus

        return (output, error, status)
        
    }
}

let opener = Bruteforce()
let keychain = opener.getKeychain()
let template = opener.getTemplate()

opener.bruteforce(template: template, keychain: keychain)
