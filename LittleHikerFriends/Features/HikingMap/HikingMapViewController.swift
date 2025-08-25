//
//  HikingMapViewController.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 8/2/25.
//

import UIKit
import NMapsMap

class HikingMapViewController: UIViewController {

    var mapView: NMFMapView!
    var userMarker: NMFMarker?
    let locationManager = LocationManager()
    
    // temporary trail data
    let testTrail: [NMGLatLng] = [
        NMGLatLng(lat: 37.61972, lng: 127.01900), // 우이역 출발 지점
        NMGLatLng(lat: 37.61990, lng: 127.02034),
        NMGLatLng(lat: 37.62045, lng: 127.02178), // 도선사 입구
        NMGLatLng(lat: 37.62165, lng: 127.02310), // 하루재 갈림길
        NMGLatLng(lat: 37.62290, lng: 127.02380), // 중턱 경사로 시작
        NMGLatLng(lat: 37.62410, lng: 127.02460),
        NMGLatLng(lat: 37.62530, lng: 127.02530), // 바위지대 시작
        NMGLatLng(lat: 37.62650, lng: 127.02600),
        NMGLatLng(lat: 37.62770, lng: 127.02675), // 백운대 정상 부근
        NMGLatLng(lat: 37.62800, lng: 127.02700)  // 백운대 정상
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = NMFMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        getTrailData()
        drawPath()
        
        locationManager.onUpdate = { [weak self] location in
            let coordinate = location.coordinate
//            let location = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)

            let location = NMGLatLng(lat: 37.600422016653, lng: 126.966631031495)

            // user location 에 따른 카메라 이동
            self?.updateCamera(at: location)
            
            // user location 에 따른 마커 이동
            self?.updateMarker(at: location, name: "me")
        }
    }
    
    private func drawPath() {
        let pathOverlay = NMFPath()
        pathOverlay.path = NMGLineString(points: testTrail)
        pathOverlay.width = 3
        pathOverlay.color = UIColor.green
        pathOverlay.mapView = mapView
    }
    
    private func updateCamera(at location: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
        mapView.moveCamera(cameraUpdate)
    }
    
    private func updateMarker(at location: NMGLatLng, name: String) {
        if let marker = userMarker {
            marker.position = location
        } else {
            let markerImageName = "tempUser"
            let originalImage = UIImage(named: markerImageName)! // [TODO]
            let resizedImage = UIImage.resize(image: originalImage, targetSize: CGSize(width: 20, height: 20))
            let overlayImage = NMFOverlayImage(image: resizedImage)
            
            let marker = NMFMarker(position: location)
            marker.captionText = name
            marker.iconImage = overlayImage
            marker.mapView = mapView
            userMarker = marker
        }
    }

}

// temp [ISSUE] Invalid API Key -> 브라우저에서는 되는뎅
extension HikingMapViewController {

    // MARK: - GeoJSON Models

    struct VWorldResponse: Codable {
        let response: FeatureResponse
    }

    struct FeatureResponse: Codable {
        let result: FeatureResult?
    }

    struct FeatureResult: Codable {
        let featureCollection: FeatureCollection
    }

    struct FeatureCollection: Codable {
        let features: [Feature]
    }

    struct Feature: Codable {
        let geometry: Geometry
        let properties: TrailProperties
    }

    struct Geometry: Codable {
        let type: String
        let coordinates: [[[Double]]]  // MultiLineString
    }

    struct TrailProperties: Codable {
        let mntn_nm: String
        let sec_len: String
        let cat_nam: String
    }

    private func getTrailData() {
        let urlString = "https://api.vworld.kr/req/data?key=\(OpenAPI.vWorldKey)&service=data&request=GetFeature&data=LT_L_FRSTCLIMB&geomFilter=BOX(126.96,37.60,127.00,37.65)&domain=127.0.0.1"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(VWorldResponse.self, from: data)
                let features = decoded.response.result?.featureCollection.features ?? []
                let coordinates: [NMGLatLng] = features.flatMap { feature in
                    feature.geometry.coordinates.flatMap { line in
                        line.map { coord in
                            NMGLatLng(lat: coord[1], lng: coord[0])
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.drawTrailPath(with: coordinates)
                }

            } catch {
                print("❌ JSON 파싱 실패:", error)
            }
        }.resume()
    }

    private func drawTrailPath(with coordinates: [NMGLatLng]) {
        let pathOverlay = NMFPath()
        pathOverlay.path = NMGLineString(points: coordinates)
        pathOverlay.width = 4
        pathOverlay.color = UIColor.systemGreen
        pathOverlay.mapView = mapView
    }
}
