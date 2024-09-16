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
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    MapView()
}
