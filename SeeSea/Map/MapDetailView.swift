//
//  MapDetailView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/24/24.
//

import SwiftUI

struct MapDetailView: View {
    let beach: Beach
    @State private var diaryEntry = ""
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @Environment(\.dismiss) var dismiss
    @State private var showingWebcam = false
    @FocusState private var isFocused: Bool
    @ObservedObject var viewModel: BeachViewModel
    @State private var diaryEntries: [DiaryEntry] = []
    
    var body: some View {
        VStack() {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
                Spacer()
                Text("\(beach.name.replacingOccurrences(of: "해수욕장", with: ""))서핑 다이어리")
                    .font(.headline)
                Spacer()
                Button("저장") {
                    saveDiaryEntry()
                    isFocused = false
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .bottom
            )
            // Date Picker
            HStack {
                Text(selectedDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { showingDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                }
            }
            .padding(20)
            // Diary Entry
            TextEditor(text: $diaryEntry)
                .focused($isFocused)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)
            .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                        Text("지난 일지")
                            .font(.headline)
                        ForEach(diaryEntries, id: \.id) { entry in
                            pastEntryView(entry: entry)
                        }
                    }
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            // Webcam View
            Button("웹캠 보러가기") {
                showingWebcam = true
                //self.selectedBeach = beach
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .presentationDetents([.height(400)])
                .onChange(of: selectedDate) { _, _ in
                    showingDatePicker = false
                }
        }
        .sheet(isPresented: $showingWebcam) {
            WebcamSheetView(beach: beach, isPresented: $showingWebcam)
        }
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            loadDiaryEntries()
        }
    }
    
    private func pastEntryView(entry: DiaryEntry) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(entry.content)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func saveDiaryEntry() {
        //TODO: ""면 "내용을 입력해주세요" Toast
        viewModel.saveDiaryEntry(beachName: beach.name, date: selectedDate, content: diaryEntry)
        diaryEntry = ""
        loadDiaryEntries()
    }
    
    private func loadDiaryEntries() {
        diaryEntries = viewModel.getDiaryEntries(for: beach.name)
    }
}

struct WebcamSheetView: View {
    let beach: Beach
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "xmark")
                })
                Spacer()
                Text(beach.name)
                    .bold()
                Spacer()
                Text("   ")  // For visual balance
            }
            .padding(10)
            
            CustomWKWebView(url: beach.url)
        }
    }
}

#Preview {
    MapDetailView(beach: Beach(name: "해운대 해수욕장", coordinate: .init(latitude: 35.158, longitude: 129.160), beachNum: "1", wh: "0.5m", url: "https://example.com/webcam", category: "서핑"), viewModel: BeachViewModel())
}
