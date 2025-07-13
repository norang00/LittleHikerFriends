//
//  ViewController.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 4/19/25.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = NMFMapView(frame: view.bounds)
        view.addSubview(mapView)

        // 지도 스타일을 '등산로가 보이는 지형지도'로 변경
        mapView.mapType = .terrain

        // 서울 근교 산 예시 위치
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.6584, lng: 126.9779))
        mapView.moveCamera(cameraUpdate)
    }
}
