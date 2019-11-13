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
import CoreLocation

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
    
    var userDetails: [String: String] {
        get {
            return defaults.value(forKey: USER_DETAILS_KEY) as! [String: String]
        }
        set {
            defaults.set(newValue, forKey: USER_DETAILS_KEY)
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
                let responseStatus = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseStatus == 1 {
                    let responseData = json["ResponseData"].dictionaryValue
                    let currentVersion = responseData["Version"]?.doubleValue
                    let upgradeFlag = responseData["Upgrade"]?.intValue
                    let instructionMsg = responseData["Message"]?.stringValue
                    let appDetailModel = AppDetailsModel(flag: upgradeFlag!, recentVersion: currentVersion!, instruction: instructionMsg!)
                    completion(responseStatus, responseMsg, appDetailModel)
                }
                else {
                    completion(responseStatus, responseMsg, nil)
                }
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
    func sendOtpForLogin(with mobileNo: String, completion: @escaping (_ status: Int, _ message: String) -> Void) {
        
        let parameter = [
            "Phone" : mobileNo
        ]
        
        Alamofire.request(URL_TO_SEND_OTP_FOR_LOGIN, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                completion(responseCode, responseMsg)
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String)
            }
        }
    }
    
    func checkOtpForLogin(with mobileNo: String, with otp: String, completion: @escaping (_ status: Int, _ message: String) -> Void) {
        
        let params = [
            "Phone": mobileNo,
            "OTP": otp
        ]
        
        Alamofire.request(URL_TO_VERIFY_OTP_FOR_LOGIN, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let responseData = json["ResponseData"].dictionaryValue
                    let userId = responseData["Id"]!.intValue
                    let firstName = responseData["FirstName"]!.stringValue
                    let lastName = responseData["LastName"]!.stringValue
                    let email = responseData["Email"]!.stringValue
                    let mobileNo = responseData["Phone"]!.stringValue
                    var userDetails = [String:String]()
                    userDetails["firstName"] = firstName
                    userDetails["lastName"] = lastName
                    userDetails["email"] = email
                    userDetails["mobileNo"] = mobileNo
                    self.userDetails = userDetails
                    self.userId = userId
                    self.isLoggedIn = true
                }
                completion(responseCode, responseMsg)
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String)
            }
        }
    }
    
    func getNearByChargers(with latitude: Double, and longitude: Double, completion: @escaping (_ status: Int, _ message: String, _ data: [ChargerModel]?) -> Void) {
        
        let params = [
            "Latitude": latitude,
            "Longitude": longitude
        ]
        
        Alamofire.request(URL_TO_GET_NEARBY_CHARGERS, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                var nearByChargers = [ChargerModel]()
                if responseCode == 1 {
                    let responseData = json["ResponseData"].arrayValue
                    for charger in responseData {
                        let chargerId = charger["Id"].intValue
                        let fName = charger["FirstName"].stringValue
                        let lName = charger["LastName"].stringValue
                        let email = charger["Email"].stringValue
                        let phone = charger["Phone"].stringValue
                        let driverStatus = charger["Status"].intValue
                        let driverFlag = charger["Flg"].intValue
                        let totalChargedCount = charger["TotalCharged"].intValue
                        let currentLatitude = charger["Latitude"].doubleValue
                        let currentLongitude = charger["Longitude"].doubleValue
                        let newCharger = ChargerModel(id: chargerId, firstName: fName, lastName: lName, email: email, phone: phone, status: driverStatus, flag: driverFlag, totalChargedCount: totalChargedCount, currentLatitude: currentLatitude, currentLongitude: currentLongitude)
                        nearByChargers.append(newCharger)
                    }
                    completion(responseCode, responseMsg, nearByChargers)
                }
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
        
    }
    
    func getVehicleType(completion: @escaping (_ status: Int, _ message: String, _ data: [VehicleTypeModel]?) -> Void) {
        
        Alamofire.request(URL_TO_GET_VEHICLE_TYPES, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                var vehicleTypes = [VehicleTypeModel]()
                if responseCode == 1 {
                    let imageUrl = json["ImageUrl"].stringValue
                    let responseData = json["ResponseData"].arrayValue
                    for vehicle in responseData {
                        let vehicleId = vehicle["Id"].intValue
                        let vehicleName = vehicle["Type"].stringValue
                        let flag = vehicle["Flg"].intValue
                        let imageLink = "\(imageUrl)\(vehicleId).png"
                        let vehicleModel = VehicleTypeModel(id: vehicleId, name: vehicleName, flag: flag, imageLink: imageLink)
                        vehicleTypes.append(vehicleModel)
                    }
                }
                completion(responseCode, responseMsg, vehicleTypes)
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
    func updateProfile(userDetails: UserDetailsModel, password: String, completion: @escaping (_ status: Int, _ message: String, _ data: UserDetailsModel?) -> Void) {
        let params: [String: Any] = [
            "Id": userDetails.userId,
            "FirstName": userDetails.firstName,
            "LastName": userDetails.lastName,
            "Email": userDetails.email,
            "Phone": userDetails.phoneNo,
            "Password": password
        ]
        
        Alamofire.request(URL_TO_UPDATE_PROFILE, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
    func bookCharger(userId: Int, vehicleId: Int, userLocation: CLLocationCoordinate2D, completion: @escaping (_ status: Int, _ message: String, _ data: OrderModel?) -> Void ) {
        let params: [String: Any] = [
            "CustomerId": userId,
            "VehicleId": vehicleId,
            "Latitude": userLocation.latitude,
            "Longitude": userLocation.longitude
        ]
        
        Alamofire.request(URL_TO_BOOK_CHARGER, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let responseData = json["ResponseData"]
                    let orderId = responseData["Id"].intValue
                    let vehicleId = responseData["VehicleId"].intValue
                    let chargerId = responseData["ChargerId"].intValue
                    let fare = responseData["Fare"].doubleValue
                    let chargerLatitude = responseData["Latitude"].doubleValue
                    let chargerLongitude = responseData["Longitude"].doubleValue
                    let chargerStatus = responseData["Status"].intValue
                    let otp = responseData["OTP"].intValue
                    var bookedTimeRaw = responseData["Booked"].stringValue
                    var bookedTime = ""
                    if bookedTimeRaw != "" {
                        if let dotRange = bookedTimeRaw.range(of: ".") {
                            bookedTimeRaw.removeSubrange(dotRange.lowerBound..<bookedTimeRaw.endIndex)
                        }
                        print(bookedTimeRaw)
                        bookedTime = self.changeDateFormat(sourceDate: bookedTimeRaw, originFormat: "yyyy-MM-dd'T'HH:mm:SS", reqFormat: "dd, MMMM, yyyy HH:mm")
                    }
                    print(bookedTime)
                    let paymentStatus = responseData["PaymentStatus"].intValue
                    let paymentType = responseData["PaymentType"].intValue
                    let transactionId = responseData["TransactionId"].stringValue
                    let declinedIds = responseData["DeclineIds"].stringValue
                    let orderModel = OrderModel(id: orderId, vehicleId: vehicleId, chargerId: chargerId, fare: fare, chargerLatitude: chargerLatitude, chargerLongitude: chargerLongitude, chargerStatus: chargerStatus, otp: otp, bookedTime: bookedTime, paymentStatus: paymentStatus, paymentType: paymentType, transactionId: transactionId, declinedIds: declinedIds)
                    completion(responseCode, responseMsg, orderModel)
                }
                else {
                    completion(responseCode, responseMsg, nil)
                }
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
    func changeDateFormat(sourceDate: String, originFormat: String, reqFormat: String) -> String {
        
        var originalDate = sourceDate
        if originalDate.contains(" ") {
            originalDate = originalDate.replacingOccurrences(of: " ", with: "")
        }
        
        if originalDate.contains(",") {
            originalDate = originalDate.replacingOccurrences(of: ",", with: "")
        }
        
        
        let string = originalDate
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_CA") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = originFormat
        let dateAru = dateFormatter.date(from: string)!
        dateFormatter.dateFormat = reqFormat
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: dateAru)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
}
