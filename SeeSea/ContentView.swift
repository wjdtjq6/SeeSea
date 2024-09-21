//
//  ContentView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedIndex = 0
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack {
                WaveForecastView()
                    .navigationTitle("예보")
            }
            .tabItem {
                Text("파도 얘보")
                Image(systemName: "water.waves")
            }
            .tag(0)
            
            NavigationStack {
                WebCamView()
                    .navigationTitle("웹캠")
            }
            .tabItem {
                Text("웹캠")
                Image(systemName: "video")
            }
            .tag(1)
            NavigationStack {
                MapView()
                    .ignoresSafeArea(.all, edges: .top)
            }
            .tabItem {
                Text("지도")
                Image(systemName: "map")
            }
//            .onAppear {
//                Coordinator.shared.checkIfLocationServiceIsEnabled()
//            }
        }
    }
}

#Preview {
    ContentView()
}
 
