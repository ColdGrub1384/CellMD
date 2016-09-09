//
//  TodayViewController.swift
//  CellMD - Run command
//
//  Created by Adrian on 9/8/16.
//  Copyright © 2016 Adrian. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var command: UILabel!
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        var script = ""
        
        let fp = popen("cat /Library/CellMD/Command","r")
        
        var buf = Array<CChar>(count: 128, repeatedValue: 0)
        
        while fgets(&buf, CInt(buf.count), fp) != nil,
            let str = String.fromCString(buf) {
                script = script+str
                
                if script != "" {
                    command.text = script
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func run(sender: AnyObject) {
        system(command.text!)
    }
    
}
