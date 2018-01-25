# CellMD
CellMD is an iOS Application for jailbroken devices to run shell commands.

# With AppSync
<a href="https://7c7a6179.dataplicity.io/CellMD.html">Install</a> (Need Jailbreak and Appsync in [Hackyouriphone repo](http://repo.hackyouriphone.org/))

# Without Jailbreak

To install CellMD without jailbreak, you can [download](https://github.com/ColdGrub1384/CellMD/raw/master/CellMD.ipa) the IPA, [download](http://www.cydiaimpactor.com/) Cydia Impactor, open it, drop the IPA in Cydia Impactor, login with your Apple ID, in the iDevice, go to: Settings > Devices management > yourmail@domain.com and trust, with this trick, CellMD 
will not have the write privileges.


##Installation on /Applications
Open the xcode project, build the project on a generic device, find the product, ssh the file in /Application directory and type in a Terminal or ssh:
```bash 
su root
[root password]
chmod 775 /Applications/CellMD.app/CellMD
uicache
```

# Sudo

You can [install](https://cydia.saurik.com/package/sudo/) sudo to root privileges.

In iFile, or other file browser, go to /etc/sudoers, edit it and add:

```
   mobile ALL=(ALL) NOPASSWD: ALL
```

Now, you can run a command as root:

```bash
   sudo [command]
````

# uicache and killall
User apps cannot run commands ```uicache``` and ```killalll```, BUT I coded an command line tool to run uicache and killall on users apps.
Install [cmd](https://7c7a6179.dataplicity.io/apt/Uploads/debs/cmd.deb) in my cydia repo: [http://7c7a6179.dataplicity.io/apt/Uploads](http://7c7a6179.dataplicity.io/apt/Uploads)

### Usage:

run as root:
```bash
cmd "command to execute"
```

or:
chmod 777 the bin of cmd:
```bash
chmod 777 /usr/bin/cmd
```

and run cmd

<h1>News</h1>

<h1>f.4</h1>
[Added] Today extention<br/>

<h1>f.3</h1>
[Added] Preference pane<br/>
[Added] Sudo before commands

<h1>f.2.4</h1>
[Fixed] Crash on startup

<h1>f.2.3</h1>
[Fixed] Edit style editing the function:
```swift
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    // to
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
```

<h1>f.2.2</h1>
[Added] Reorder cells: 
```swift

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    @IBAction func reorder(sender: AnyObject) {
        if tableView.editing == true {
            tableView.setEditing(false, animated: true)
        }else {
            tableView.setEditing(true, animated: true)
        }
    }
```
<br/>
[Added] Clear history: 
```swift
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

```
<br/>
[Fixed] New icon:
<br/>

<h1>f.2.1</h1>
[Added] History:
```swift

class CommandsTableViewController: UITableViewController {
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var controller: HistoryTableViewController = segue.destinationViewController as! HistoryTableViewController
        controller.history = history
    }
}

class HistoryTableViewController: UITableViewController {
    
    var history: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("items", forIndexPath: indexPath)
        
        cell.textLabel!.text = history[indexPath.row]
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIPasteboard.generalPasteboard().string = history[indexPath.row]
        
        let alert = UIAlertController(title: "Copied!", message: "\"\(history[indexPath.row])\" is copied.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    

    }
```
<br/>
[Added] Quick commands:
```swift
   @IBOutlet weak var quickcmd: UITextField!
   
   @IBAction func sendcommand(sender: AnyObject) {
        
        if quickcmd.text == "clear" || quickcmd.text == "clear;" {
            history.append(quickcmd.text!)
            var historysaved = NSUserDefaults.standardUserDefaults()
            historysaved.setValue(history, forKey: "History")
            historysaved.synchronize()
            logtext.text = ""
        }else {
        
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
```
<br/>
[Fixed] Changed UITextView with log text theme:
```swift
       @IBAction func DarkVoid(sender: AnyObject) {
        var darksaved = NSUserDefaults.standardUserDefaults()
        if Dark.on == true {
            logtext.backgroundColor = .blackColor()
            logtext.textColor = .whiteColor()
        }else {
            logtext.backgroundColor = .whiteColor()
            logtext.textColor = .blackColor()
        }
    }
```
<br/>

<h1>f.1.1</h1>
[Added] Initial version


#Screenshots
![1](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/1.PNG)
![2](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/2.PNG)
![3](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/3.PNG)
![4](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/4.PNG)
![5](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/5.PNG)
![6](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/6.PNG)
![7](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/7.PNG)
![8](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/8.PNG)
![9](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/9.PNG)
![10](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/10.PNG)
![11](https://7c7a6179.dataplicity.io/Jailbreak/apt/CellMD/Github/11.PNG)
