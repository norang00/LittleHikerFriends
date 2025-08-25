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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = NMFMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        // 초기 카메라 위치를 북한산 중앙으로 설정
        setInitialCameraPosition()
        
        // VWorld API에서 실제 등산로 데이터 가져오기 (주석 처리됨)
        // getTrailData()
        
        // 네이버 지도를 기본 지도 타입으로 설정
        mapView.mapType = .basic

        locationManager.onUpdate = { [weak self] location in
            
            // MARK: - 실제 사용자 위치 사용
            let coordinate = location.coordinate
            let userLocation = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            print("🎯 실제 위치 업데이트: \(userLocation.lat), \(userLocation.lng)")

            // user location 에 따른 카메라, 마커 이동
            self?.updateCamera(at: userLocation)
            self?.updateMarker(at: userLocation, name: "나")
        }
    }
    
    // MARK: - 초기 카메라 위치 설정 (임시)
    private func setInitialCameraPosition() {
        // 북한산 중앙 위치 (정확한 좌표)
        let bukhanMountainCenter = NMGLatLng(lat: 37.660779, lng: 126.978799)
        let cameraUpdate = NMFCameraUpdate(scrollTo: bukhanMountainCenter, zoomTo: 14)
        mapView.moveCamera(cameraUpdate)
        
        print("📍 카메라 위치: 북한산 백운대 (37.660779, 126.978799)")
    }
    
    // MARK: - 사용자 위치 추적 시작/중지 메서드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startLocationUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopLocationUpdates()
    }
    
    private func updateCamera(at location: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
        mapView.moveCamera(cameraUpdate)
    }
    
    private func updateMarker(at location: NMGLatLng, name: String) {
        if let marker = userMarker {
            // 기존 마커 위치 업데이트
            marker.position = location
            print("📍 마커 위치 업데이트: \(location.lat), \(location.lng)")
        } else {
            // 새 사용자 마커 생성
            let marker = NMFMarker(position: location)
            marker.captionText = name
            
            // 사용자 위치를 나타내는 파란색 마커
            marker.iconImage = NMF_MARKER_IMAGE_BLUE
            marker.width = 30
            marker.height = 40
            
            // 지도에 마커 추가
            marker.mapView = mapView
            userMarker = marker
            
            print("✅ 사용자 마커 생성: \(name) at (\(location.lat), \(location.lng))")
        }
    }
}

// MARK: - VWorld API Integration (주석 처리됨)
/*
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
        // 북한산 영역 좌표
        let minX = 126.9500, minY = 37.5800
        let maxX = 127.0500, maxY = 37.6800
        
        var comps = URLComponents(string: "https://api.vworld.kr/req/data")!
        comps.queryItems = [
            URLQueryItem(name: "key", value: OpenAPI.vWorldKey),
            URLQueryItem(name: "service", value: "data"),
            URLQueryItem(name: "request", value: "GetFeature"),
            URLQueryItem(name: "data", value: "LT_L_FRSTCLIMB"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "size", value: "1000"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "geomFilter", value: "BOX(\(minX),\(minY),\(maxX),\(maxY))"),
            URLQueryItem(name: "attrFilter", value: "mntn_nm:like:북한산")
        ]
        
        guard let url = comps.url else { 
            print("❌ URL 생성 실패")
            return 
        }

        var request = URLRequest(url: url)
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        print("🌐 VWorld API 요청: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP 상태 코드: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(VWorldResponse.self, from: data)
                
                guard let features = decoded.response.result?.featureCollection.features else {
                    print("❌ 등산로 데이터 없음")
                    return
                }
                
                print("✅ 등산로 \(features.count)개 발견")
                
                // 각 등산로를 개별적으로 처리
                for feature in features {
                    let mountainName = feature.properties.mntn_nm
                    let trailName = feature.properties.cat_nam
                    let trailLength = feature.properties.sec_len
                    
                    print("🏔️ \(mountainName) - \(trailName) (\(trailLength)km)")
                    
                    for lineString in feature.geometry.coordinates {
                        let coordinates = lineString.map { NMGLatLng(lat: $0[1], lng: $0[0]) }
                        if coordinates.count >= 2 {
                            DispatchQueue.main.async {
                                self.drawIndividualTrail(
                                    coordinates: coordinates,
                                    trailName: "\(mountainName) - \(trailName)"
                                )
                            }
                        }
                    }
                }

                print("📍 등산로 그리기 완료")

            } catch {
                print("❌ JSON 파싱 실패: \(error)")
            }
        }.resume()
    }

    // MARK: - 개별 등산로 그리기
    private func drawIndividualTrail(coordinates: [NMGLatLng], trailName: String) {
        let pathOverlay = NMFPath()
        pathOverlay.path = NMGLineString(points: coordinates)
        pathOverlay.width = 5
        pathOverlay.color = UIColor.systemGreen
        pathOverlay.outlineWidth = 1
        pathOverlay.outlineColor = UIColor.darkGreen
        pathOverlay.mapView = mapView
        
        print("🛤️ 등산로 그리기: \(trailName) (\(coordinates.count)개 포인트)")
    }
}
*/
