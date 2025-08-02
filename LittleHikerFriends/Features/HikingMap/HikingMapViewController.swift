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
        
        drawPath()
        
        locationManager.onUpdate = { [weak self] location in
            let coordinate = location.coordinate
            let location = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)

            // user location 에 따른 마커 이동
            self?.updateMarker(at: location, name: "me")

            // user location 에 따른 카메라 이동
            let cameraUpdate = NMFCameraUpdate(scrollTo: location)
            self?.mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func drawPath() {
        let pathOverlay = NMFPath()
        pathOverlay.path = NMGLineString(points: [
            NMGLatLng(lat: 37.57152, lng: 126.97714),
            NMGLatLng(lat: 37.56607, lng: 126.98268),
            NMGLatLng(lat: 37.56445, lng: 126.97707),
            NMGLatLng(lat: 37.55855, lng: 126.97822)
        ])
        pathOverlay.mapView = mapView
    }
    
    private func updateCamera(location: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
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
