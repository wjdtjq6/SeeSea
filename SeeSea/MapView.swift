//
//  MapView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/16/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var locationManager = CLLocationManager()
        
    var body: some View {
            Map(position: $cameraPosition) {
                annotation(title: "월정리 해수욕장", coordinate: .woljeongri, wave: "0")
                annotation(title: "삼양검은 모래 해수욕장", coordinate: .samyangBlackSand, wave: "0-1")
                annotation(title: "송정 해수욕장", coordinate: .songjeong, wave: "1-2")
                annotation(title: "경포 해수욕장", coordinate: .gyeongpo, wave: "2-3")
                annotation(title: "다대포 해수욕장", coordinate: .dadaepo, wave: "3-4")
                annotation(title: "진하 해수욕장", coordinate: .jinha, wave: "4-5")
                annotation(title: "곽지과물 해수욕장", coordinate: .gwakjiGwamul, wave: "5-6")
                annotation(title: "협재 해수욕장", coordinate: .hyeopjae, wave: "6-7")
                annotation(title: "중문ㆍ색달 해수욕장", coordinate: .jungmunSaekdal, wave: "7-8")
                annotation(title: "이호테우 해수욕장", coordinate: .ihoTeu, wave: "8-9")
                annotation(title: "함덕서우봉 해수욕장", coordinate: .hamdeokSeoubong, wave: "9-10")
            }
            .onAppear {
                if let location = locationManager.location {
                    let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4))
                    cameraPosition = .region(region)
                }
            }
            .overlay {
                Button(action: {
                    print("LOCATION")
                }, label: {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.5))
                            .frame(width: 50, height: 50)
                        Image(systemName: "location")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                })
                .frame(width: 20, height: 20)
                .position(x: UIScreen.main.bounds.width-40, y: UIScreen.main.bounds.height-210)
                
                Button(action: {
                    print("around")
                }, label: {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.5))
                            .frame(width: 50, height: 50)
                        Image(systemName: "dot.scope")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                })
                .frame(width: 20, height: 20)
                .position(x: UIScreen.main.bounds.width-40, y: UIScreen.main.bounds.height-150)

//
            }
            
            //.frame(maxWidth: .infinity)
        
        
    }
    func annotation(title: String, coordinate: CLLocationCoordinate2D, wave: String) -> some MapContent{
        Annotation(title, coordinate: coordinate) {
            Text("  \(wave)  ")
                .bold()
                .foregroundColor(.white)
                .padding(5)
                .background(.blue)
                .clipShape(.rect(cornerRadius: 30))
        }
    }

}

#Preview {
    MapView()
}
