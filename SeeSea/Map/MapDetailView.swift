//
//  MapDetailView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/24/24.
//

import SwiftUI

struct MapDetailView: View {
    let beach: Beach
        
        var body: some View {
            VStack {
                Text("서핑 일지")
                    .font(.title)
                Spacer()
                CustomWKWebView(url: beach.url)
            }
            .navigationTitle(beach.name)
        }
}

#Preview {
    MapDetailView(beach: Beach(name: "", coordinate: .dadaepo, beachNum: "", wh: "", url: "", category: ""))
}
