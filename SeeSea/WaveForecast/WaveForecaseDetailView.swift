//
//  WaveForecaseDetailView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/29/24.
//

import SwiftUI

struct WaveForecaseDetailView: View {
    @StateObject private var viewModel = WaveForecastViewModel()
    let beachNum: String

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: [.sectionHeaders], content: {
                ForEach(groupedForecastItems, id: \.0) { (date, items) in
                    Section {
                        SectionView(items: items)
                    } header: {
                        Text(formatDate(date))
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                    }

                }
            })
        }
        .onAppear(perform: {
            viewModel.fetchForecastData(for: beachNum)
        })
    }
    private var groupedForecastItems: [(String, [ForecastItem])] {
        Dictionary(grouping: viewModel.forecastItems) { $0.fcstDate }
            .sorted { $0.key < $1.key }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
        return dateString
    }
}
struct SectionView: View {
    let items: [ForecastItem]
    
    var body: some View {
        HStack {
            Text("시간")
            Spacer()
            Text("바람")
            Spacer()
            Text("날씨")
            Spacer()
            Text("파고")
        }
        .bold()
        //                            .font(.headline)
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        
        ForEach(items, id: \.fcstTime) { item in
            HStack {
                Text(formatTime(item.fcstTime))
//                if item.description.count == 1 {
//                    Text("0\(item)시")
//                } else {
//                    Text("\(item)시")
//                }
                Spacer()
//                Image(systemName: "location.north.fill")
//                    .foregroundColor(.blue)
//                Text("2.1m/s")
                windInfo(uuu: item.uuu, vvv: item.vvv, wsd: item.wsd)
                Spacer()
//                Image(systemName: "sun.max")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                if wt.description.count == 1 {
//                    Text(" \(wt)°C")
//                } else {
//                    Text("\(wt)°C")
//                }
                weatherInfo(tmp: item.tmp)
                Spacer()
                Text(item.wav)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
    }
    private func formatTime(_ timeString: String) -> String {
        return timeString.prefix(2) + "시"
    }
    
    private func windInfo(uuu: String, vvv: String, wsd: String) -> some View {
        HStack {
            Image(systemName: "location.north.fill")
                .rotationEffect(.degrees(calculateWindDirection(uuu: uuu, vvv: vvv)))
            Text("\(wsd)m/s")
        }
    }
    
    private func weatherInfo(tmp: String) -> some View {
        HStack {
            Image(systemName: "thermometer")
            Text("\(tmp)°C")
        }
    }
    
    private func calculateWindDirection(uuu: String, vvv: String) -> Double {
        guard let u = Double(uuu), let v = Double(vvv) else { return 0 }
        let radius = atan2(u, v)
        let degrees = radius * 180 / .pi
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}
#Preview {
    WaveForecaseDetailView(beachNum: "347")
}
