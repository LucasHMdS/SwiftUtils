//
//  GPSSingleton.swift
//  SwiftUtils
//
//  Created by Lucas Henrique Machado da Silva on 07/05/2018.
//  Copyright © 2018 Lucas Henrique Machado da Silva. All rights reserved.
//  See the file "LICENSE" for the full license governing this code.
//

import Foundation
import CoreLocation

enum GPSAuthorizationType {
    case whenInUse
    case always
}

enum GPSError: Error {
    case authorizationTypeNotSet
    case authorizationDenied
    case authorizationPrivacyNotSet
    case locationsEmpty
}

class GPS: NSObject {
    // MARK: - Singleton
    static let shared = GPS()
    
    // MARK: - Constants
    private let locationManager = CLLocationManager()
    
    // MARK: - Variables
    private var maxLocations: Int = 20
    private var authorizationType: GPSAuthorizationType?
    private var locations = [CLLocation]()
    
    // MARK: - Initializers
    private override init() {
        super.init()
        
        self.locationManager.delegate = self
        if (self.isValidAuthorization()) {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Setters
    func setAuthorizationType(_ authorizationType: GPSAuthorizationType) {
        self.authorizationType = authorizationType
    }
    
    func setMaxLocations(_ count: Int) {
        self.maxLocations = count
    }
    
    func setActivityType(_ activityType: CLActivityType) {
        self.locationManager.activityType = activityType
    }
    
    func setDesiredAccuracy(_ desiredAccuracy: CLLocationAccuracy) {
        self.locationManager.desiredAccuracy = desiredAccuracy
    }
    
    func setDistanceFilter(_ distanceFilter: CLLocationDistance) {
        self.locationManager.distanceFilter = distanceFilter
    }
    
    // MARK: - Public
    func start() throws {
        try self.validateAuthorization()
        
        self.locationManager.startUpdatingLocation()
    }
    
    func stop() throws {
        self.locationManager.stopUpdatingLocation()
    }
    
    func getLastLocations() throws -> [CLLocation] {
        guard (self.locations.count > 0) else {
            throw GPSError.locationsEmpty
        }
        
        return self.locations.reversed()
    }
    
    func getCurrentLocation() throws -> CLLocation {
        guard let location = self.locations.last else {
            throw GPSError.locationsEmpty
        }
        
        return location
    }
    
    // MARK: - Private Helpers
    private func validateAuthorization() throws {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            if let authorizationType = self.authorizationType {
                if (authorizationType == .whenInUse) {
                    self.locationManager.requestWhenInUseAuthorization()
                } else {
                    self.locationManager.requestAlwaysAuthorization()
                }
            } else {
                throw GPSError.authorizationTypeNotSet
            }
        }
        
        if (CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted) {
            throw GPSError.authorizationDenied
        }
        
    }
    
    private func isValidAuthorization() -> Bool {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            return true
        } else {
            return false
        }
    }
}

extension GPS: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
        
        let difference = self.locations.count - self.maxLocations
        if (difference > 0) {
            self.locations.removeFirst(difference)
        }
    }
}
