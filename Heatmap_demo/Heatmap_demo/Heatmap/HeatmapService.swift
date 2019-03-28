//
//  WebService.swift
//  SinghaSaleVisit
//
//  Created by Detchat Boonpragob on 12/6/2560 BE.
//  Copyright © 2560 Zoso. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    func iso8601() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        
        return formatter.string(from: self)
    }
}

typealias WSCallback<T:Codable> = (_ response:WSResponse<T>?,_ error:Error?) -> Void

class HeatmapService {
    
    static var hostURL:String {
        get {
            var value = "http://0.0.0.0:8080/"
            value = "http://35.222.100.65/"
            return value
        }
    }
    
    enum HTTPRequestType : Int {
        case httpRequestGet,httpRequestPost,httpRequestPut
        func toKey() -> String! {
            switch self {
            case .httpRequestPost:
                return "POST"
            case .httpRequestGet:
                return "GET"
            case .httpRequestPut:
                return "PUT"
            }
        }
    }
    
    enum ContentType : Int {
        case form,json
        
        func toKey() -> String! {
            switch self {
            case .form:
                return "application/x-www-form-urlencoded"
            case .json:
                return "application/json"
            }
        }
    }
    
    var loadTask:URLSessionDataTask?
    
    
    static func create<T>(url:URL, requestType : HTTPRequestType , contentType : ContentType , header : Dictionary<String,String>? = nil , isIgnoreGeneralHeader:Bool = false, data : Dictionary<String,Any>?,completion :@escaping WSCallback<T> ) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.setValue(contentType.toKey(), forHTTPHeaderField: "Content-Type")
        request.httpMethod = requestType.toKey()
        
        if header != nil {
            for key in header!.keys {
                request.setValue(header![key]!, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = data {
            switch requestType {
            case .httpRequestGet,.httpRequestPut:
                if let urlString = request.url?.absoluteString
                {
                    let newURL = "\(urlString)?\(String(describing: bodyData.toGetDataString()))"
                    request.url = URL(string: newURL)
                }
                break
            case .httpRequestPost:
                var body:String?
                switch contentType {
                case .form:
                    body = bodyData.toPostDataString()
                    break
                case .json:
                    body = bodyData.toJsonString()
                    break
                }
                dump(body)
                request.httpBody = body?.data(using: .utf8)
                break
                
            }
        }
        
        print("requestURL = \(request.url?.absoluteString)")
        print("requestHeader = \(String(describing: request.allHTTPHeaderFields))")
        print("requestBody = \(String(describing: request.httpBody))")
        
        let session = URLSession.shared;
        return session.dataTask(with: request) { (data, response, error) in
            
            if let errorResponse = error {
                DispatchQueue.main.async {
                    completion(nil, errorResponse)
                }
            }else if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode / 100 != 2 {
                    
                    var errorResponse = NSError(domain: "Domain", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey :"Http status code has unexpected value"])
                    do {
                        let wsResponse = try JSONDecoder().decode(WSResponse<T>.self, from: data!)
                        
                        if wsResponse.message != nil {
                            errorResponse = NSError(domain: "Error from service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : wsResponse.message!])
                        }
                    }
                    catch {
                    }
                    
                    DispatchQueue.main.async {
                        print(errorResponse)
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                    }
                    
                }else{
                    let responseText = String(data: data!, encoding: String.Encoding.utf8)
                    print("success \(request.url!.absoluteString)")
                    print(responseText ?? "")
                    
//                    let str = GenClassHelper.sharedInstance.genClassFromJSON(responseText!, className: "newClass")
//                   print(str)
                    
                    do {
                        let wsResponse = try JSONDecoder().decode(WSResponse<T>.self, from: data!)
                        
                        DispatchQueue.main.async {
                            completion(wsResponse, nil)
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                    
                }
            }
        }
    }
    
    class func GenAlertController(_ error:NSError?) -> UIAlertController? {
        
        if error != nil
        {
            
            var alert : UIAlertController?
            
            if error?.code == -1009 || error?.code == -1200
            {
                alert = UIAlertController(title: "Please connect Internet", message: "", preferredStyle: UIAlertController.Style.alert)
                alert?.addAction(UIAlertAction(title:"ok", style: UIAlertAction.Style.cancel, handler: nil))
            }
            else
            {
                alert = UIAlertController(title: "error", message: "\(error!.code)  \(error?.localizedDescription ?? "")", preferredStyle: UIAlertController.Style.alert)
                alert?.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: nil))
            }
            
            return alert
            
            
        }
        else{
            
            return nil
        }
    }
    
    //MARK:- service
    enum Endpoint {
        case StartSession,UploadLog,GetHeatmapInApp,GetHeatmapLocation
        func urlString() -> String {
            switch self {
            case .StartSession:
                return "\(HeatmapService.hostURL)heatmap/session"
            case .UploadLog:
                return "\(HeatmapService.hostURL)heatmap/log"
            case .GetHeatmapInApp:
                return "\(HeatmapService.hostURL)heatmap/screen"
            case .GetHeatmapLocation:
                return "\(HeatmapService.hostURL)heatmap/map"
            }
        }
    }
    
    
    static func startSession(_ appSecret:String, lat:Double,lng:Double,timestamp:Date, handler:@escaping WSCallback<LogHeader>) -> URLSessionTask {
        var header:Dictionary<String, String> = Dictionary<String, String>()
        header["app_secret"] = appSecret
        
        var body:Dictionary<String, Any> = Dictionary<String, Any>()
        body["latitude"] = lat
        body["longitude"] = lng
        body["timestamp"] = timestamp.iso8601()
        
        
        return HeatmapService.create(url: URL(string:Endpoint.StartSession.urlString())!, requestType: HeatmapService.HTTPRequestType.httpRequestPost, contentType: HeatmapService.ContentType.json, header:header, data: body, completion: handler)
    }
    
    static func uploadLog(_ appSecret:String, logHeader:LogHeader, handler:@escaping WSCallback<Int>) -> URLSessionTask {
        var header:Dictionary<String, String> = Dictionary<String, String>()
        header["app_secret"] = appSecret
        
        let body:Dictionary<String, Any> = logHeader.dictionary!
        
        
        
        return HeatmapService.create(url: URL(string:Endpoint.UploadLog.urlString())!, requestType: HeatmapService.HTTPRequestType.httpRequestPost, contentType: HeatmapService.ContentType.json,header:header , data: body, completion: handler)
    }
    
    
    static func getHeatmapInApp(_ appID:String, handler:@escaping WSCallback<String>) -> URLSessionTask {
        var header:Dictionary<String, String> = Dictionary<String, String>()
        header["Authorization"] = "218bd293c4f3419688344f3b86018fb4" // demo token
        
        var body:Dictionary<String, Any> =  Dictionary<String, Any>()
        body["device"] = 1
        body["app_id"] = "5c9ab5d98dc8506272e167a8" // demo appID
        
        
        
        return HeatmapService.create(url: URL(string:Endpoint.GetHeatmapInApp.urlString())!, requestType: HeatmapService.HTTPRequestType.httpRequestGet, contentType: HeatmapService.ContentType.json,header:header , data: body, completion: handler)
    }
    
    
    
}
