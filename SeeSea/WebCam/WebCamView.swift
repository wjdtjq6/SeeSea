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
            CategoryBar(categories: categories, selectedCategory: $selectedCategory)
                
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(viewModel.beaches, id: \.name) { beach in
                        BeachGridItem(beach: beach)
                    }
                }
                //.padding()
            }
        }
    }
    
}
struct BeachGridItem: View {
    let beach: Beach
    let size = UIScreen.main.bounds.width/3-2
    var body: some View {
        NavigationLink {
            CustomWKWebView(url: beach.url)
                .navigationTitle(beach.name)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image("surf-4")
                    .resizable()
                    .frame(width: size ,height: size)
                    .aspectRatio(contentMode: .fill)
                
                VStack(alignment: .leading) {
                    Text("양양") // 실제로는 해변의 지역을 표시해야 합니다
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(beach.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(5)
            }
            .background(Color.black.opacity(0.5))
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
                        print(category)
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
