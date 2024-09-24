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
                Text(beach.name)
                    .font(.headline)
                // 여기에 추가적인 해변 정보를 표시할 수 있습니다.
            }
        }
}

#Preview {
    MapDetailView(beach: Beach(name: "", coordinate: .dadaepo, beachNum: "", wh: "", url: "", category: ""))
}
