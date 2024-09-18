//
//  MapView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/16/24.
//

import SwiftUI
import NMapsMap

struct MapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator.shared
    }
    func makeUIView(context: Context) -> some UIView {
        context.coordinator.getNaverMapView()
        
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.setMarker(lat: 37.4797729789029, lng: 126.897860359752, title: "집")
        context.coordinator.setMarker(lat: 33.4977677, lng: 126.44805, title: "제주서프로와 이호점")
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)
//        context.coordinator.setMarker(lat: <#T##Double#>, lng: <#T##Double#>, title: <#T##String#>)



    }
}

#Preview {
    MapView()
}
