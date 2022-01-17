//
//  ContentView.swift
//  osusume_Project
//
//  Created by Yoonjae lee on 2022/01/17.
//

import SwiftUI

struct Response: Codable {
    var top: [Result]
}

struct Result: Codable {
    var mal_id: Int
    var rank: Int
    var title: String
    var type: String
    var start_data: String?
    var image_url: String
}

struct ContentView: View {
    
    @State private var str2 = ""
    @State private var str3 = ""
    
    func loadData() {
        
        str2 = String("\(pageno[page])/")
        
        str3 = String("\(subtype[subTypeSelection])")
        
        let str1 = "https://api.jikan.moe/v3/top/anime/"
        
        guard let url = URL(string: str1 + str2 + str3)
                
        else {
            print("Invalid url")
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request){
            
            data, response, error in
            
            if let data = data {
                if let decodeResponse = try?
                    JSONDecoder().decode(Response.self, from: data) {
                    //our data is fine so we can go back tothe main to the main thread now
                    
                    DispatchQueue.main.async {
                        // this will update the UI
                        self.top = decodeResponse.top
                    }
                    return
                }
            }
            
            //if comes down here that means some problem has occured
            
            print("Fetch Failed: \(error?.localizedDescription ?? "Unknown.error")")
        }.resume()
    }
    
    var subtype = ["airing", "upcoming", "tv", "movie", "ova", "special", "bypopularity", "favorite"]
    var pageno = [1,2,3,4,5,6]
    
    @State private var page = 0
    
    @State private var subTypeSelection = 1
    
    
    @State private var top = [Result]()
    
    var body: some View {
        VStack{
            Text("Your Anime List")
                .font(.largeTitle)
                .fontWeight(.ultraLight)
//                .foregroundColor(.red)
            Picker("Your selection", selection:  $subTypeSelection) {
                ForEach(0..<8) {
                    something in
                    Text("\(subtype[something])")
                }
            }.pickerStyle(SegmentedPickerStyle())
                .onChange(of: subTypeSelection) { value in
                    loadData()
            }
            
            Picker("Your selection", selection:  $page) {
                ForEach(0..<6) {
                    something in
                    Text("\(pageno[something])")
                }
            }.pickerStyle(SegmentedPickerStyle())
                .onChange(of: page) { value in
                    loadData()
            }
        }
        
        
        NavigationView {
            List(top, id: \.mal_id) { item in
                
                HStack{
                    
                    AsyncImage(url: URL(string: item.image_url)!,
                                   placeholder: { Text("Loading ...") },
                                   image: { Image(uiImage: $0).resizable() })
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.title2)
                        Text(String("\(item.rank)"))
                            .font(.headline)
                            .foregroundColor(.green)
                        Text(item.type)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(item.start_data ?? "")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                }
                
                
            }.onAppear(perform: loadData)
            
            .navigationBarTitle("Osusume")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
