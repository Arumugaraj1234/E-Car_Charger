//
//  Constants.swift
//  E-CarCharger
//
//  Created by MacBook Pro on 2019-10-31.
//  Copyright © 2019 Peach. All rights reserved.
//

import Foundation

//MARK: USERDEFAULTS KEYS
let LOGGED_IN_KEY = "loggedIn"
let USER_ID_KEY = "userId"

//MARK: SEGUE IDENTIFIERS
let NEARBY_CHARGERS_TO_TRACK_CHARGER = "nearByChargersToTrackCharger"
let NEARBY_CHARGERS_TO_HISTORY = "nearByChargersToHistory"

//MARK: URL CONSTANTS
let BASE_URL = "http://101.53.153.54/ElectricCharger/WebService/api/Customer/"
let URL_TO_GET_APP_INIT = BASE_URL + "AppInit"
let URL_TO_LOGIN = BASE_URL + "Login"
let URL_TO_VERIFY_OTP = BASE_URL + "VerifyOTP"
let URL_TO_UPDATE_PROFILE = BASE_URL + "UpdateProfile"
let URL_TO_GET_NEARBY_CHARGERS = BASE_URL + "GetNearestChargers"
let URL_TO_BOOK_CHARGER = BASE_URL + "BookCharge"
let URL_TO_TRACK_CHARGER = BASE_URL + "TrackCharger"
let URL_TO_GET_ALL_BOOKINGS = BASE_URL + "MyBookings"
let URL_TO_GET_VEHICLES = BASE_URL + "GetVehicles"
let URL_TO_CHECK_BOOKING = BASE_URL + "CheckBooking"

//MARK: HEADER
let HEADER = [
    "Content-Type": "application/json"
]
