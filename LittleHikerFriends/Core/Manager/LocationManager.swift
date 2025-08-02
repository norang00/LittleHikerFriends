//
//  LocationManager.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 8/3/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onUpdate: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latest = locations.last {
            onUpdate?(latest)
        }
        
        // [TODO] 주기 갱신 관리하기
    }
}
