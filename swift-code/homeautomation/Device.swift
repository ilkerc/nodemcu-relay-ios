//
//  Device.swift
//  homeautomation
//
//  Created by ilker on 04/06/2017.
//  Copyright © 2017 ilker. All rights reserved.
//

import Foundation
import ObjectMapper

class Device: Mappable {

    var pinNo: Int?
    var switchState: Bool?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        pinNo <- map["p"]
        switchState <- map["s"]
    }

}
