//
//  ViewController.swift
//  homeautomation
//
//  Created by ilker on 04/06/2017.
//  Copyright © 2017 ilker. All rights reserved.
//

import UIKit
import PubNub
import ObjectMapper

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var devices = [Device]()
    var client: PubNub!

    override func viewDidLoad() {
        super.viewDidLoad()
        initPubNub()
    }
    
    func initPubNub() {
        let configuration = PNConfiguration(publishKey: "your-pub-key", subscribeKey: "your-sub-key")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        self.client.subscribeToChannels(["ProjectChannel"], withPresence: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    @IBAction func refreshClicked(_ sender: UIButton) {
        let dict = ["p": -1, "s": 0]
        self.client.publish(dict, toChannel: "ProjectChannel", withCompletion: nil)
    }
}

extension ViewController: PNObjectEventListener {
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        // Handle new message stored in message.data.message
        if let _message = message.data.message as? [String: Any] {
            if let arrMsg = _message["devices"] as? [[String : Any]] {
                self.devices = Mapper<Device>().mapArray(JSONArray: arrMsg)
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "circuit_cell", for: indexPath) as! CircuitCell
        let device = self.devices[indexPath.row]
        cell.pinNo.text = "Pin \(device.pinNo!)"
        cell.switchState.setOn(device.switchState!, animated: false)
        cell.OnSwitchStateChange = {
            device.switchState = cell.switchState.isOn
            self.client.publish(device.toJSON(), toChannel: "ProjectChannel", withCompletion: nil)
        }
        return cell
    }
}
