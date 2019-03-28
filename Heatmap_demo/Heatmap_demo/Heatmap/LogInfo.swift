//
//  MemberInfo.swift
//  SinghaSaleVisit
//
//  Created by Detchat Boonpragob on 12/4/2560 BE.
//  Copyright © 2560 Zoso. All rights reserved.
//

import Foundation
import UIKit

class LogHeader:Codable {
    var sessionId:String? = ""
    var logList:[LogInfo]?
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case logList = "log_array"
    }
}

class LogInfo:Codable {
    var device:Int? = 1
    var screenSize:[CGFloat]?
    var position:[CGFloat]?
    var timestamp:String?
    
    enum CodingKeys: String, CodingKey {
        case device = "device"
        case screenSize = "screen_size"
        case position = "position"
        case timestamp = "timestamp"
    }
}



class HeatmapScreen:Codable {
    var position:[CGFloat]?
    var count:Int?
    
    enum CodingKeys: String, CodingKey {
        case position = "_id"
        case count = "count"
    }
}



