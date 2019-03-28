//
//  WSResponse.swift
//  SinghaSaleVisit
//
//  Created by Detchat Boonpragob on 27/3/2561 BE.
//  Copyright © 2561 Zoso. All rights reserved.
//

import Foundation


class WSResponse<T:Codable>:Codable {
    var data:T?
    var message:String?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
    }
}
