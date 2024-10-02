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
    private var groupedForecastItems: [(String, [CombinedForecastItem])] {
        Dictionary(grouping: viewModel.combinedForecastItems) { $0.fcstDate }
            .sorted { $0.key < $1.key }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
        return dateString
    }
}
struct SectionView: View {
    let items: [CombinedForecastItem]
    
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
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        
        ForEach(items, id: \.fcstTime) { item in
            HStack {
                Text(formatTime(item.fcstTime))
                Spacer()
                windInfo(uuu: item.uuu, vvv: item.vvv, wsd: item.wsd)
                Spacer()
                weatherInfo(tmp: item.tmp, sky: item.sky, pty: item.pty)
                Spacer()
                formatWaveHeight(item.wav)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
    }
    private func formatWaveHeight(_ wav: String) -> some View {
        return Text(String(format: "%.1f",  Double(wav)!)+"m")
    }
    private func formatTime(_ timeString: String) -> String {
        return timeString.prefix(2) + "시"
    }
    
    private func windInfo(uuu: String, vvv: String, wsd: String) -> some View {
        HStack {
            Image(systemName: "location.north.fill")
                .rotationEffect(.degrees(calculateWindDirection(uuu: uuu, vvv: vvv)))
            Text(String(format: "%.1f", Double(wsd)!)+"m/s")
        }
    }
    
    private func weatherInfo(tmp: String, sky: String, pty: String) -> some View {
        HStack {
            weatherIcon(sky: sky, pty: pty)
            Text("\(tmp)°C")
        }
    }
    private func weatherIcon(sky: String, pty: String) -> some View {
        let skyCode = Int(sky) ?? 0
        let ptyCode = Int(pty) ?? 0
        
        switch (skyCode, ptyCode) {
            // 맑음 (SKY: 1)
            case (1, 0): return Image(systemName: "sun.max.fill")           // 맑음
            case (1, 1): return Image(systemName: "sun.rain.fill")          // 맑음, 비
            case (1, 2): return Image(systemName: "sun.rain.fill")          // 맑음, 비/눈
            case (1, 3): return Image(systemName: "sun.snow.fill")          // 맑음, 눈
            case (1, 4): return Image(systemName: "sun.rain.fill")          // 맑음, 소나기
            
            // 구름많음 (SKY: 3)
            case (3, 0): return Image(systemName: "cloud.fill")         // 구름많음
            case (3, 1): return Image(systemName: "cloud.sun.rain.fill")    // 구름많음, 비
            case (3, 2): return Image(systemName: "cloud.sun.rain.fill")    // 구름많음, 비/눈
            case (3, 3): return Image(systemName: "cloud.snow.fill")    // 구름많음, 눈 11
            case (3, 4): return Image(systemName: "cloud.drizzle.fill")    // 구름많음, 소나기 00
            
            // 흐림 (SKY: 4)
            case (4, 0): return Image(systemName: "smoke.fill")             // 흐림
            case (4, 1): return Image(systemName: "cloud.rain.fill")        // 흐림, 비
            case (4, 2): return Image(systemName: "cloud.rain.fill")       // 흐림, 비/눈
            case (4, 3): return Image(systemName: "cloud.snow.fill")        // 흐림, 눈 11
            case (4, 4): return Image(systemName: "cloud.drizzle.fill")   // 흐림, 소나기 00
            
            // 기본값 (예상치 못한 코드 조합)
            default: return Image(systemName: "questionmark.circle.fill")   // 알 수 없는 날씨
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
