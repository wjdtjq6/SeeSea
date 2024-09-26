//
//  WebCamView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/15/24.
//

import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: String
}

struct WebCamView: View {
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
   
    let columns = [
       GridItem(.flexible(),spacing: 3),
       GridItem(.flexible(),spacing: 3),
       GridItem(.flexible(),spacing: 3)
    ]
    var body: some View {
        VStack(spacing: 0) {
            CategoryBar(categories: categories, selectedCategory: $viewModel.selectedCategory)
                
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(viewModel.filteredBeaches, id: \.name) { beach in
                        BeachGridItem(viewModel: viewModel, beach: beach)
                    }
                }
            }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            viewModel.objectWillChange.send()
        }
    }
    
}
struct BeachGridItem: View {
    @ObservedObject var viewModel: BeachViewModel
    let beach: Beach
    let size = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationLink {
            CustomWKWebView(url: beach.url)
                .navigationTitle(beach.name)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(beach.name)
                    .resizable()
                    .frame(width: size/3-2 ,height: size/3-2)
                    .aspectRatio(contentMode: .fill)
                
                Color.black.opacity(0.3)
                
                VStack(alignment: .leading) {
                    Text(beach.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Text(beach.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(10)
                
                Button(action: {
                    viewModel.toggleFavorite(for: beach)
                }, label: {
                    Image(systemName: viewModel.isFavorite(beach) ? "heart.fill" : "heart")
                    .resizable()
                    .foregroundColor(.white)
                     .frame(width: 20, height: 20)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(10)
            }
        }
    }
}
struct CategoryBar: View {
    let categories: [Category]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category.name
                    }) {
                        Text(category.name)
                            .foregroundColor(selectedCategory == category.name ? .blue : .gray)
                            .font(.title3)
                            .bold()
                    }
                }
            }
            .padding()
        }
    }
}
#Preview {
    WebCamView()
}
