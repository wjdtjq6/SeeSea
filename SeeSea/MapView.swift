//
//  MapView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/16/24.
//

import SwiftUI
import MapKit
//import CoreLocation

struct MapView: View {
    @StateObject private var viewModel = BeachViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
            Map(position: $cameraPosition) {
                ForEach(viewModel.beaches, id: \.name) {
                    beach in
                    annotation(beach: beach)
                }
                UserAnnotation()
            }
            .onAppear {
                moveToCurrentLocation()
            }
            .overlay {
                Button {
                    withAnimation {
                        moveToNearestBeach()
                    }
                    
                } label: {
                    CircleButton(imageName: "location")
                }
                .frame(width: 20, height: 20)
                .position(x: 40, y: UIScreen.main.bounds.height-150)
                
                Button {
                    withAnimation {
                        moveToCurrentLocation()
                    }
                    
                } label: {
                    CircleButton(imageName: "scope")
                }
                .frame(width: 20, height: 20)
                .position(x: UIScreen.main.bounds.width-40, y: UIScreen.main.bounds.height-150)
            }
    }
    func annotation(beach: Beach) -> some MapContent {
        Annotation(beach.name, coordinate: beach.coordinate) {
            Text("  \(viewModel.beachData[beach.name]?.wave)  ")
                .bold()
                .foregroundColor(.white)
                .padding(5)
                .background(.blue)
                .clipShape(.rect(cornerRadius: 30))
        }
    }
    func moveToCurrentLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
            cameraPosition = .region(region)
        }
    }
    func moveToNearestBeach() {
        guard let userLocation = locationManager.location else { return }
        
        let nearestBeach = viewModel.beaches.min { beach1, beach2 in
            distance(from: userLocation.coordinate, to: beach1.coordinate) < distance(from: userLocation.coordinate, to: beach2.coordinate)
        }
        
        if let nearestBeach = nearestBeach {
            withAnimation {
                let region = MKCoordinateRegion(center: nearestBeach.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
                cameraPosition = .region(region)
            }
        }
    }
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
//    func annotation(title: String, coordinate: CLLocationCoordinate2D, wave: String) -> some MapContent{
//        Annotation(title, coordinate: coordinate) {
//            Text("  \(wave)  ")
//                .bold()
//                .foregroundColor(.white)
//                .padding(5)
//                .background(.blue)
//                .clipShape(.rect(cornerRadius: 30))
//        }
//    }

}
struct CircleButton: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.5))
                .frame(width: 50, height: 50)
            Image(systemName: imageName)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        }
    }
}
#Preview {
    MapView()
}
