//
//  CommandsTableViewController.swift
//  CellMD
//
//  Created by Adrian on 7/30/16.
//  Copyright © 2016 Adrian. All rights reserved.
//
// Version f.2.4

import UIKit
import Foundation
import Darwin

class CommandsTableViewController: UITableViewController {
    
    var dark = false
    
    var commands = ["echo \"Made By ColdGrub1384\"","echo \"If you want to use the widget you need to have Jailbreak and Sudo installed and configurated, Open CellMD and put the command(s) in /Library/CellMD/Command\""]
    var history: [String] = []
    
    var before = ""
    
    var sudo = false
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var switchview: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var logtext: UITextView!
    
    @IBOutlet weak var quickcmd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        system("sudo mkdir /Library/CellMD")
        system("sudo touch /Library/CellMD/Command")
        system("sudo chmod 777 /Library/CellMD/Command")
        
        quickcmd.text = NSUserDefaults.standardUserDefaults().valueForKey("widgetcmd") as! String!
        
        let commandssaved = NSUserDefaults.standardUserDefaults()
        if commandssaved.valueForKey("commands") != nil {
            commands = commandssaved.valueForKey("commands") as! [String]
            self.tableView.reloadData()
        }
        
        var Settings = NSUserDefaults.standardUserDefaults()
        if Settings.valueForKey("DarkMode") != nil {
            if Settings.valueForKey("DarkMode") as! Bool == true {
               dark = true
               self.view.backgroundColor = .blackColor()
               switchview.backgroundColor = .blackColor()
               logtext.backgroundColor = .blackColor()
               logtext.textColor = .whiteColor()
               self.navigationController?.navigationBar.tintColor = .blackColor()
               self.tableView.reloadData()
            }
        }
        
        if Settings.valueForKey("command") != nil {
            before = Settings.valueForKey("command") as! String
            print(before)
        }
        
        
        if Settings.valueForKey("sudo") != nil {
            sudo = Settings.valueForKey("sudo") as! Bool
        }
        
        var historysaved = NSUserDefaults.standardUserDefaults()
        if historysaved.valueForKey("History") != nil {
            history = historysaved.valueForKey("History") as! [String]
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let item = commands[sourceIndexPath.row]
        
        commands.removeAtIndex(sourceIndexPath.row)
        commands.insert(item, atIndex: destinationIndexPath.row)
        
        let commandssaved = NSUserDefaults.standardUserDefaults()
        commandssaved.setValue(self.commands, forKey: "commands")
        commandssaved.synchronize()
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commands.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("command", forIndexPath: indexPath)
        cell.textLabel!.text = commands[indexPath.row]
        if  dark == true {
            cell.textLabel!.textColor = .whiteColor()
            cell.backgroundColor = .blackColor()
        }else {
            cell.textLabel!.textColor = .blackColor()
            cell.backgroundColor = .whiteColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var fp = popen("", "r")
        
        if sudo == true {
            fp = popen("sudo "+commands[indexPath.row], "r")
        }else if before != "" {
            fp = popen(before+" "+commands[indexPath.row], "r")
        }else {
            fp = popen(commands[indexPath.row], "r")
        }
        
        var buf = Array<CChar>(count: 128, repeatedValue: 0)
        
        while fgets(&buf, CInt(buf.count), fp) != nil,
            let str = String.fromCString(buf) {
                logtext.text = logtext.text+str
        }
        
        history.append(commands[indexPath.row])
        var historysaved = NSUserDefaults.standardUserDefaults()
        historysaved.setValue(history, forKey: "History")
        historysaved.synchronize()
    }


    
    @IBAction func add(sender: AnyObject) {
         let alert = UIAlertController(title: "Add command", message: "Please type your command in the text field", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (UITextField) in
            UITextField.placeholder = "Command to add"
        }
        
        let textfield = alert.textFields![0]
        
        let action = UIAlertAction(title: "Add", style: .Default) { (UIAlertAction) in
            self.commands.append(textfield.text!)
            self.tableView.reloadData()
            let commandssaved = NSUserDefaults.standardUserDefaults()
            commandssaved.setValue(self.commands, forKey: "commands")
            commandssaved.synchronize()
        }
        
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (UITableViewRowAction, NSIndexPath) in
            let command = self.commands[indexPath.row]
            let alert = UIAlertController(title: "Edit", message: "Please type the new command in the text field", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (UITextField) in
                UITextField.text = command
                UITextField.placeholder = "New command"
            })
            let textfield = alert.textFields![0]
            let action = UIAlertAction(title: "Edit", style: .Default, handler: { (UIAlertAction) in
                self.commands[indexPath.row] = textfield.text!
                self.tableView.reloadData()

            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        let removeAction = UITableViewRowAction(style: .Normal, title: "Delete") { (UITableViewRowAction, NSIndexPath) in
            self.commands.removeAtIndex(indexPath.row)
            let commandssaved = NSUserDefaults.standardUserDefaults()
            commandssaved.setValue(self.commands, forKey: "commands")
            commandssaved.synchronize()
            self.tableView.reloadData()
        }
        
        editAction.backgroundColor = .blueColor()
        removeAction.backgroundColor = .redColor()
        
        return [editAction, removeAction]
    }
    
    @IBAction func clear(sender: AnyObject) {
        logtext.text = ""
    }
    
    
    @IBAction func sendcommand(sender: AnyObject) {
        
        if quickcmd.text == "clear" || quickcmd.text == "clear;" {
            history.append(quickcmd.text!)
            var historysaved = NSUserDefaults.standardUserDefaults()
            historysaved.setValue(history, forKey: "History")
            historysaved.synchronize()
            logtext.text = ""
        }else {
        
            if sudo == true {
               quickcmd.text = "sudo "+quickcmd.text!
            }else if before != "" {
                quickcmd.text = before+" "+quickcmd.text!
            }else {
                print("...")
            }
            
            let fp = popen(quickcmd.text!, "r")
            var buf = Array<CChar>(count: 128, repeatedValue: 0)
        
            while fgets(&buf, CInt(buf.count), fp) != nil,
                let str = String.fromCString(buf) {
                   logtext.text = logtext.text+str
            }
            
            history.append(quickcmd.text!)
            var historysaved = NSUserDefaults.standardUserDefaults()
            historysaved.setValue(history, forKey: "History")
            historysaved.synchronize()
        }
        
        quickcmd.text = ""
        quickcmd.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var controller: HistoryTableViewController = segue.destinationViewController as! HistoryTableViewController
        controller.history = history
    }
    
    @IBAction func pastecmd(sender: AnyObject) {
        quickcmd.text = UIPasteboard.generalPasteboard().string
    }
    
    
    @IBAction func reorder(sender: AnyObject) {
        if tableView.editing == true {
            tableView.setEditing(false, animated: true)
        }else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func trash(sender: AnyObject) {
        let alert = UIAlertController(title: "Remove", message: "Remove, history or all commands?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        let rmhistory = UIAlertAction(title: "History", style: .Default) { (UIAlertAction) in
            self.history = []
            let historysaved = NSUserDefaults.standardUserDefaults()
            historysaved.setValue(self.history, forKey: "History")
            historysaved.synchronize()
        }
        
        let rmcells = UIAlertAction(title: "All commands", style: .Default) { (UIAlertAction) in
            self.commands = []
            self.tableView.reloadData()
            let commandssaved = NSUserDefaults.standardUserDefaults()
            commandssaved.setValue(self.commands, forKey: "commands")
            commandssaved.synchronize()
            
        }
        
        alert.addAction(rmhistory)
        alert.addAction(rmcells)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}

