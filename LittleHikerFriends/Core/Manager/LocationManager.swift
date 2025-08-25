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
    
    private var isLocationUpdateRequested = false
    
    override init() {
        super.init()
        manager.delegate = self
        
        // 실시간 추적
        manager.desiredAccuracy = kCLLocationAccuracyBest // 최고 정확도
        
        // 초기 권한 요청
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - 위치 추적 시작
    func startLocationUpdates() {
        isLocationUpdateRequested = true
        
        // 권한 상태에 따라 처리 (동기 호출 없이)
        handleAuthorizationStatus()
    }
    
    // MARK: - 위치 추적 중지
    func stopLocationUpdates() {
        isLocationUpdateRequested = false
        manager.stopUpdatingLocation()
        print("⏹️ 위치 추적 중지")
    }
    
    // MARK: - 권한 상태 처리
    private func handleAuthorizationStatus() {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if isLocationUpdateRequested {
                manager.startUpdatingLocation()
                print("✅ 위치 추적 시작")
            }
        case .denied, .restricted:
            print("❌ 위치 권한이 거부되었습니다.")
            isLocationUpdateRequested = false
        case .notDetermined:
            print("⏳ 위치 권한 요청 중...")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        onUpdate?(latest)
        print("📍 실시간 위치 업데이트: \(latest.coordinate.latitude), \(latest.coordinate.longitude)")
    }
    
    // MARK: - 권한 상태 변경 처리
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📍 위치 권한 상태 변경: \(authorizationStatusString(status))")
        
        // 권한 상태가 변경되면 요청된 위치 업데이트 처리
        handleAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    // MARK: - Helper
    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "미결정"
        case .restricted: return "제한됨"
        case .denied: return "거부됨"
        case .authorizedAlways: return "항상 허용"
        case .authorizedWhenInUse: return "앱 사용 중 허용"
        @unknown default: return "알 수 없음"
        }
    }
}
