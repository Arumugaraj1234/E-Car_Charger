//
//  Constants.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-31.
//  Copyright © 2019 Peach. All rights reserved.
//

import UIKit

//MARK: USERDEFAULTS KEYS
let LOGGED_IN_KEY = "loggedIn"
let USER_ID_KEY = "userId"
let USER_DETAILS_KEY = "UserDetails"

//MARK: SEGUE IDENTIFIERS
let NEARBY_CHARGERS_TO_TRACK_CHARGER = "nearByChargersToTrackCharger"
let NEARBY_CHARGERS_TO_HISTORY = "nearByChargersToHistory"

//MARK: URL CONSTANTS
let BASE_URL = "http://101.53.153.54/ElectricCharger/WebService/api/Customer/"
let URL_TO_GET_APP_INIT = BASE_URL + "AppInit"
let URL_TO_SEND_OTP_FOR_LOGIN = BASE_URL + "SendLoginOTP"
let URL_TO_VERIFY_OTP_FOR_LOGIN = BASE_URL + "CheckLoginOTP"
let URL_TO_UPDATE_PROFILE = BASE_URL + "UpdateProfile"  //Not Yet
let URL_TO_GET_NEARBY_CHARGERS = BASE_URL + "GetNearestChargers"
let URL_TO_BOOK_CHARGER = BASE_URL + "BookCharge"  //Not Yet
let URL_TO_TRACK_CHARGER = BASE_URL + "TrackCharger"  //Not Yet
let URL_TO_GET_ALL_BOOKINGS = BASE_URL + "MyBookings"  //Not Yet
let URL_TO_GET_VEHICLE_TYPES = BASE_URL + "GetVehicles"
let URL_TO_CHECK_BOOKING = BASE_URL + "CheckBooking"  //Not Yet

//MARK: GOOGLE MAP URL CONSTANTS
let GOOGLE_URL_FOR_GEOCODING =  "https://maps.googleapis.com/maps/api/geocode/json?"
let GOOGLE_URL_FOR_DIRECTIONS = "https://maps.googleapis.com/maps/api/directions/json?"
let GOOGLE_URL_FOR_ADDRESS = "https://maps.googleapis.com/maps/api/geocode/json?"

//MARK: HEADER
let HEADER = [
    "Content-Type": "application/json"
]

//MARK: FONTS

