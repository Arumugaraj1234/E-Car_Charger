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
            "CustomerId": userDetails.userId,
            "FirstName": userDetails.firstName,
            "LastName": userDetails.lastName,
            "Email": userDetails.email,
            "Phone": userDetails.phoneNo,
            "Password": password
        ]
        
        Alamofire.request(URL_TO_UPDATE_PROFILE, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let responseData = json["ResponseData"]
                    let firstName = responseData["FirstName"].stringValue
                    let lastName = responseData["LastName"].stringValue
                    let email = responseData["Email"].stringValue
                    let phoneNo = responseData["Phone"].stringValue
                    var userDetails = [String:String]()
                    userDetails["firstName"] = firstName
                    userDetails["lastName"] = lastName
                    userDetails["email"] = email
                    userDetails["mobileNo"] = phoneNo
                    self.userDetails = userDetails
                    let userModel = UserDetailsModel(userId: self.userId, firstName: firstName, lastName: lastName, email: email, phoneNo: phoneNo)
                    completion(responseCode, responseMsg, userModel)
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
    
    func bookCharger(userId: Int, vehicleId: Int, userLocation: CLLocationCoordinate2D, completion: @escaping (_ status: Int, _ message: String, _ data: OrderBookModel?) -> Void ) {
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
                    let orderModel = OrderBookModel(id: orderId, vehicleId: vehicleId)
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
        return dateString
    }
    
    func checkBookingStatus(orderId: Int, vehicleType: Int, userLocation: CLLocationCoordinate2D, completion: @escaping (_ status: Int, _ message: String, _ data: Int?) -> Void) {
        
        let params: [String: Any] = [
            "BookingId": orderId,
            "VehicleId": vehicleType,
            "Latitude": userLocation.latitude,
            "Longitude": userLocation.longitude
        ]
        
        Alamofire.request(URL_TO_CHECK_BOOKING, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let chargerId = json["ResponseData"].intValue
                    completion(responseCode, responseMsg, chargerId)
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
    
    func trackCharger(chargerId: Int, completiion: @escaping (_ status: Int, _ message: String, _ data: ChargerModel?) -> Void) {
        let params = [
            "ChargerId": chargerId
        ]
        
        Alamofire.request(URL_TO_TRACK_CHARGER, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let responseData = json["ResponseData"]
                    let chargerId = responseData["Id"].intValue
                    let firstName = responseData["FirstName"].stringValue
                    let lastName = responseData["LastName"].stringValue
                    let email = responseData["Email"].stringValue
                    let phone = responseData["Phone"].stringValue
                    let status = responseData["Status"].intValue
                    let flag = responseData["Flg"].intValue
                    let totalCharged = responseData["TotalCharged"].intValue
                    let chargerLatitude = responseData["Latitude"].doubleValue
                    let chargerLongitude = responseData["Longitude"].doubleValue
                    let chargerModel = ChargerModel(id: chargerId, firstName: firstName, lastName: lastName, email: email, phone: phone, status: status, flag: flag, totalChargedCount: totalCharged, currentLatitude: chargerLatitude, currentLongitude: chargerLongitude)
                    completiion(responseCode, responseMsg, chargerModel)
                }
                else {
                    completiion(responseCode, responseMsg, nil)
                }
            }
            else {
                debugPrint(response.error as Any)
                completiion(-2, response.error as! String, nil)
            }
        }
    }
    
    func autoCancelOfOrder(orderId: Int, completion: @escaping (_ status: Int, _ message: String) -> Void) {
        let params = [
            "BookingId": orderId
        ]
        
        Alamofire.request(URL_TO_AUTO_CANCEL_OF_ORDER, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
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
    
    func verifyOtpForUpdatePhoneNo(userId: Int, phone: String, otp: String, completiion: @escaping (_ status: Int, _ message: String) -> Void) {
        
        let params: [String: Any] = [
            "CustomerId": userId,
            "Phone": phone,
            "OTP": otp
        ]
        
        Alamofire.request(URL_TO_VERIFY_OTP_FOR_UPDATE_PHONENO, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                if responseCode == 1 {
                    let userDetails = self.userDetails
                    let fName = userDetails["firstName"] ?? ""
                    let lName = userDetails["lastName"] ?? ""
                    let email = userDetails["email"] ?? ""
                    
                    var userData = [String:String]()
                    userData["firstName"] = fName
                    userData["lastName"] = lName
                    userData["email"] = email
                    userData["mobileNo"] = phone
                    self.userDetails = userData
                }
                completiion(responseCode, responseMsg)
            }
            else {
                debugPrint(response.error as Any)
                completiion(-2, response.error as! String)
            }
        }
    }
    
    func getOrderHistory(userId: Int, completion: @escaping (_ status: Int, _ message: String, _ orders: [OrderModel]?) -> Void ) {
        
        let params = [
            "CustomerId": userId
        ]
        
        Alamofire.request(URL_TO_GET_ALL_BOOKINGS, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                var orders = [OrderModel]()
                if responseCode == 1 {
                    let responseData = json["ResponseData"].arrayValue
                    for order in responseData {
                        let orderId = order["BookingId"].intValue
                        let vehicleName = order["VehileName"].stringValue
                        let imageLink = order["VehileImage"].stringValue
                        let chargerName = order["ChargerName"].stringValue
                        let fare = order["Fare"].doubleValue
                        let latitude = order["Latitude"].doubleValue
                        let longitude = order["Longitude"].doubleValue
                        let otp = order["OTP"].intValue
                        var bookedDate = order["Booked"].stringValue
                        var bookedTime = ""
                        if bookedDate != "" {
                            if let dotRange = bookedDate.range(of: ".") {
                                bookedDate.removeSubrange(dotRange.lowerBound..<bookedDate.endIndex)
                            }
                            bookedTime = self.changeDateFormat(sourceDate: bookedDate, originFormat: "dd-MM-yyyyHH:mma", reqFormat: "dd, MMMM, yyyy HH:mm a")
                        }
                        let paymentStatus = order["PaymentStatus"].stringValue
                        let orderStatus = order["Status"].stringValue
                        let orderModel = OrderModel(orderId: orderId, vehicleName: vehicleName, vehicleImageLink: imageLink, chargerName: chargerName, fare: fare, latitude: latitude, longitude: longitude, otp: otp, bookedTime: bookedTime, paymentStatus: paymentStatus, status: orderStatus)
                        orders.append(orderModel)
                    }
                }
                completion(responseCode, responseMsg, orders)
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
    func cancelOrderByUser(orderId: Int, userId: Int, completion: @escaping (_ status: Int, _ message: String, _ data: [OrderModel]?) -> Void) {
        let params = [
            "BookingId": orderId,
            "CustomerId": userId
        ]
        
        Alamofire.request(URL_TO_CANCEL_ORDER_BY_USER, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
            if  response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                let responseCode = json["ResponseCode"].intValue
                let responseMsg = json["ResponseMessage"].stringValue
                var orders = [OrderModel]()
                if responseCode == 1 {
                    let responseData = json["ResponseData"].arrayValue
                    print(responseData)
                    for order in responseData {
                        let orderId = order["BookingId"].intValue
                        let vehicleName = order["VehileName"].stringValue
                        let imageLink = order["VehileImage"].stringValue
                        let chargerName = order["ChargerName"].stringValue
                        let fare = order["Fare"].doubleValue
                        let latitude = order["Latitude"].doubleValue
                        let longitude = order["Longitude"].doubleValue
                        let otp = order["OTP"].intValue
                        var bookedDate = order["Booked"].stringValue
                        var bookedTime = ""
                        if bookedDate != "" {
                            if let dotRange = bookedDate.range(of: ".") {
                                bookedDate.removeSubrange(dotRange.lowerBound..<bookedDate.endIndex)
                            }
                            bookedTime = self.changeDateFormat(sourceDate: bookedDate, originFormat: "dd-MM-yyyyHH:mma", reqFormat: "dd, MMMM, yyyy HH:mm a")
                        }
                        let paymentStatus = order["PaymentStatus"].stringValue
                        let orderStatus = order["Status"].stringValue
                        let orderModel = OrderModel(orderId: orderId, vehicleName: vehicleName, vehicleImageLink: imageLink, chargerName: chargerName, fare: fare, latitude: latitude, longitude: longitude, otp: otp, bookedTime: bookedTime, paymentStatus: paymentStatus, status: orderStatus)
                        orders.append(orderModel)
                    }
                }
                completion(responseCode, responseMsg, orders)
            }
            else {
                debugPrint(response.error as Any)
                completion(-2, response.error as! String, nil)
            }
        }
    }
    
}
