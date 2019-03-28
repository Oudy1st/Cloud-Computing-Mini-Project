//
//  Number+Math.swift
//  RamaApp
//
//  Created by Detchat Boonpragob on 3/2/2560 BE.
//  Copyright © 2560 Vaetita Yusabye. All rights reserved.
//

import UIKit

extension Int {
    func displayAsBadge() -> String? {
        switch self {
        case _ where self <= 0:
            return nil
        case _ where self > 99:
            return "99+"
        default:
            return "\(self.description)"
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Floor the double to decimal places value
    func floorTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self * divisor) / divisor
    }
    
    /// Ceil the double to decimal places value
    func ceilTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return ceil(self * divisor) / divisor
    }
 
}


extension CGFloat {
    /// Rounds to decimal places value
    func roundTo(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Floor to decimal places value
    func floorTo(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return floor(self * divisor) / divisor
    }
    
    /// Ceil to decimal places value
    func ceilTo(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return ceil(self * divisor) / divisor
    }
    
    func maxTo(max:CGFloat) -> CGFloat {
        if self > max
        {
            return max
        }
        else
        {
            return self
        }
    }
    
    func minTo(min:CGFloat) -> CGFloat {
        if self < min
        {
            return min
        }
        else
        {
            return self
        }
    }
}
