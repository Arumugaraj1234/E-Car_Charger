//
//  WebRequestService.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-30.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON

class WebRequestService: NSObject {
    
    private override init() {}
    static let shared = WebRequestService()
    
    //MARK: UserDefault Variables
    let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var userId: Int {
        get {
            return defaults.value(forKey: USER_ID_KEY) as! Int
        }
        set {
            defaults.set(newValue, forKey: USER_ID_KEY)
        }
    }
    

    func getAppInitDetails(completion: @escaping (_ status:Int, _ message:String, _ result:AppDetailsModel?)-> Void) {
        
        let params = [
            "Id" : 2
        ]
        
        Alamofire.request(URL_TO_GET_APP_INIT, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                print(json)
                let responseStatus = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseStatus == 1 {
                    let responseData = json["ResponseData"].dictionaryValue
                    let currentVersion = responseData["Version"]?.doubleValue
                    let upgradeFlag = responseData["Upgrade"]?.intValue
                    let instructionMsg = responseData["Message"]?.stringValue
                    let appDetailModel = AppDetailsModel(flag: upgradeFlag!, recentVersion: currentVersion!, instruction: instructionMsg!)
                    completion(responseStatus, responseMsg, appDetailModel)
                } else {
                    completion(responseStatus, responseMsg, nil)
                }
            } else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
}
