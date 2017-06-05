//
//  TableViewCell.swift
//  homeautomation
//
//  Created by ilker on 04/06/2017.
//  Copyright © 2017 ilker. All rights reserved.
//

import UIKit

class CircuitCell: UITableViewCell {
    
    var OnSwitchStateChange : (() -> Void)? = nil

    @IBOutlet weak var pinNo: UILabel!
    @IBOutlet weak var switchState: UISwitch!
    
    @IBAction func switchStateChanged(_ sender: UISwitch) {
        if let OnSwitchStateChange = self.OnSwitchStateChange {
            OnSwitchStateChange()
        }
    }
}
