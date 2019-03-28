//
//  HeatmapHandler.swift
//  Heatmap_demo
//
//  Created by Detchat Boonpragob on 27/3/2562 BE.
//  Copyright © 2562 qmul. All rights reserved.
//

import Foundation
import UIKit

class HeatmapSession: NSObject
{
    static let sharedInstance:HeatmapSession = HeatmapSession()
    
    let appSecret = "d2cfd740c4d94a0e9ff8c31fe4e5e64d"

    var screenSize:CGSize = CGSize.zero
    var logInteraction:[LogInfo] = [LogInfo]()
    var logHeader:LogHeader = LogHeader()
    
    func addInteraction(_ point:CGPoint)  {
        screenSize = UIScreen.main.bounds.size
        
        
        let logInfo = LogInfo()
        logInfo.screenSize = [screenSize.width, screenSize.height]
        logInfo.position = [point.x, point.y]
        logInfo.timestamp = Date().iso8601()
        
        logInteraction.append(logInfo)
    }
    
    func uploadLog()  {
        if logHeader.sessionId == nil || logHeader.sessionId?.count == 0 {
            let task = HeatmapService.startSession(appSecret,
                                        lat: Double(LocationSession.sharedInstance.currentLat),
                                        lng: Double(LocationSession.sharedInstance.currentLong),
                                        timestamp: Date())
            { (wsResponse, error) in
                var errorMsg = ""
                if error != nil {
                    errorMsg = error!.localizedDescription
                }
                else if let response = wsResponse
                {
                    if let info = response.data {
                        
                        DispatchQueue.main.async {
                            self.logHeader = info
                            self.uploadLog()
                        }
                        return
                    }
                    else
                    {
                        errorMsg = response.message ?? "no data"
                    }
                }
                
                print(errorMsg)
            }
            
            task.resume()
        }
        else
        {
            let uploadingLog = self.logInteraction
            self.logInteraction.removeAll()
            
            
            logHeader.logList = uploadingLog
            if logHeader.logList?.count ?? 0 > 0 {
                let task = HeatmapService.uploadLog(appSecret, logHeader: self.logHeader) { (wsResponse, error) in
                    var errorMsg = ""
                    if error != nil {
                        errorMsg = error!.localizedDescription
                        
                        self.logInteraction.insert(contentsOf: uploadingLog, at: 0)
                    }
                    else if let response = wsResponse
                    {
                        return
                    }
                    
                    print(errorMsg)
                }
                task.resume()
            }
        }
    }
    
}
