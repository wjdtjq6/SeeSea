//
//  WaveForecastView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/15/24.
//

import SwiftUI

struct WaveForecastView: View {
    @StateObject private var viewModel = BeachViewModel()
    @State private var selectedCategory = "양양"

    let categories = [
        Category(name: "전체"),
        Category(name: "관심지역"),
        Category(name: "제주"),
        Category(name: "부산"),
        Category(name: "강릉"),
        Category(name: "울산"),
        Category(name: "서해")
    ]
    
    var body: some View {
        VStack() {
            CategoryBar(categories: categories, selectedCategory: $viewModel.selectedCategory)
                
            ScrollView {
                LazyVStack(spacing: 3) {
                    ForEach(viewModel.filteredBeaches, id: \.name) { beach in
                        BeachVStackItem(viewModel: viewModel, beach: beach)
                    }
                }
            }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            viewModel.objectWillChange.send()
        }
        .onAppear {
            viewModel.fetchWhData()
            viewModel.fetchWtData()
        }
    }
}

struct BeachVStackItem: View {
    @ObservedObject var viewModel: BeachViewModel
    let beach: Beach
    @State private var wh: String = "Loading..."
    @State private var wt: String = "Loading..."
    let size = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationLink {
            WaveForecaseDetailView(beachNum: beach.beachNum)
                .navigationTitle(beach.name)
        } label: {
            ZStack(alignment: .leading) {
                
                Image(beach.name)
                    .resizable()
                    .frame(width: size ,height: size/5)
                    .aspectRatio(contentMode: .fill)
                
                Color.black.opacity(0.3)
                
                HStack {
                    Button(action: {
                        viewModel.toggleFavorite(for: beach)
                    }, label: {
                        Image(systemName: viewModel.isFavorite(beach) ? "heart.fill" : "heart")
                        .resizable()
                         .frame(width: 20, height: 20)
                    })
                    .padding(10)
                    
                    VStack(alignment: .leading) {
                        Text(beach.category)
                        Text(beach.name)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("수온 \(beach.wt)°C")
                        Text("파고 \(beach.wh)m")
                            .fontWeight(.bold)
                    }
                    .padding()
                }
                .foregroundColor(.white)
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Text("An error occurred:")
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
}

struct WaveForecastView_Previews: PreviewProvider {
    static var previews: some View {
        WaveForecastView()
    }
}
