//
//  ViewController.swift
//  Euclid
//
//  Created by RealKGB on 6/29/23.
//  Copyright © 2023 RealKGB. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var directory = ""
    var files: [EuclidFile] = []
    
    let fileManager = FileManager.default
    
    let tableView = UITableView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2))
    let textField = UITextField(frame: CGRect(x: 50, y: 30, width: UIScreen.main.bounds.width-100, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(fileManager.isReadableFile(atPath: "/private/var/mobile/")) { //shows app data directory if sandbox exists
            directory = "/private/var/mobile/"
        } else {
            directory = "/"
        }
        updateFiles()
        
        textField.borderStyle = .roundedRect
        textField.placeholder = directory
        textField.text = directory
        textField.isUserInteractionEnabled = true
        textField.delegate = self
        self.view.addSubview(textField)
        
        let linnmonView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        linnmonView.addSubview(tableView)
        self.view.addSubview(linnmonView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print(files[indexPath.row].name + " at " + String(describing: indexPath))
        if indexPath.row == 0 {
            cell.textLabel?.text = ".."
        } else if files[indexPath.row].name.hasSuffix("/") {
            cell.textLabel?.text = removeLastChar(files[indexPath.row].name)
        } else {
            cell.textLabel?.text = files[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedString = files[indexPath.row].name
        defaultAction(selectedString)
    }
    
    func defaultAction(_ file: String) {
        if file == ".." {
            goBack()
        } else if file.hasSuffix("/") {
            directory += file
            updateFiles()
        }
        print("Executing action for string: \(file)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            directory = updatedText
        }
        
        return true
    }
    
    func updateFiles() {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: directory)
            var tempFiles: [String]
            tempFiles = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
            files = []
            for i in 0..<contents.count {
                files.append(EuclidFile(name: tempFiles[i], fullPath: directory + tempFiles[i], isSelected: false))
            }
        } catch {
            print(error.localizedDescription)
        }
        textField.text = directory
        tableView.reloadData()
        print(files)
    }
    
    func goBack() {
        var components = directory.split(separator: "/")
        
        if components.count > 1 {
            components.removeLast()
            directory = "/" + components.joined(separator: "/") + "/"
            if (directory == "//"){
                directory = "/"
            }
        } else {
            directory = "/"
        }
        updateFiles()
    }
    
    func substring(str: String, startIndex: String.Index, endIndex: String.Index) -> Substring {
        let range: Range = startIndex..<endIndex
        return str[range]
    }
    
    func removeLastChar(_ string: String) -> String {
        return String(substring(str: string, startIndex: string.index(string.startIndex, offsetBy: 0), endIndex: string.index(string.endIndex, offsetBy: -1)))
    }
}

struct EuclidFile {
    var name: String
    var fullPath: String
    var isSelected: Bool
}
