//
//  ContentView.swift
//  FurtuneTelling&Memes
//
//  Created by Emir Byashimov on 28.09.2024.
//

import SwiftUI

struct Meme: Codable, Identifiable {
    let id: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
    }
}

struct MemeResponse: Codable {
    let data: MemeData
}

struct MemeData: Codable {
    let memes: [Meme]
}

struct ContentView: View {
    
    @State private var userInput: String = ""
    @State private var meme: Meme?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Введите запрос", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: fetchMeme) {
                    Label("Получить мем", systemImage: "arrow.right")
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                if isLoading {
                    ProgressView()
                } else if let meme = meme {
                    AsyncImage(url: URL(string: meme.url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 300)
                    } placeholder: {
                        ProgressView()
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Поиск мемов")
            .padding()
        }
    }
    
    private func fetchMeme() {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Correct API URL
        let apiUrl = "https://api.imgflip.com/get_memes"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Нет данных"
                    return
                }
                
                do {
                    let memeResponse = try JSONDecoder().decode(MemeResponse.self, from: data)
                    self.meme = memeResponse.data.memes.randomElement() // Show a random meme
                } catch {
                    self.errorMessage = "Ошибка при декодировании данных"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
