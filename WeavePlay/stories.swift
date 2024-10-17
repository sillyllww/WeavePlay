import Foundation
import SwiftUI

// Scene 结构体
import Foundation

// Plot 结构体
struct Plot: Identifiable,Codable {
    var storyText: String
    var id: UUID = UUID()
    var imageUrl: URL?
    var characterUrls: [URL]
    var characters: [String]
    var location: [Int] // 二维数组，存储位置信息
    var dialog:[String]
    var isturn: [Int]
    var turninfo: [String]
    var plotchose : [PlotChoice]
    var plotchoseindex : Int
    var promotechara : [String]
    var promote: String
    
    init(storyText: String, imageUrl: URL, characterUrls: [URL], characters: [String], location: [Int],dialog:[String],isturn: [Int],turninfo: [String],plotchose : [PlotChoice],plotchoseindex : Int,promotechara : [String],promote: String) {
        self.storyText = storyText
        self.imageUrl = imageUrl
        self.characters = characters
        self.location = location
        self.characterUrls = characterUrls
        self.dialog = dialog
        self.isturn = isturn
        self.turninfo = turninfo
        self.plotchose = plotchose
        self.plotchoseindex = plotchoseindex 
        self.promotechara = promotechara
        self.promote = promote
    }

}
struct PlotChoice: Codable {
    var perPlot: String
    var perCharacter: [String]
    var perdialog: [String]
    
    enum CodingKeys: String, CodingKey {
        case perPlot = "plot"
        case perCharacter = "characters"
        case perdialog = "dialogues"
    }
}//临时储存解析的数据
struct StoryContainer: Codable {
    var stories: [PlotChoice]
}
// Plots 结构体
struct Plots: Codable {
    var plots: [Plot] = []

    func savePlots(to url: URL) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(plots)
        try data.write(to: url)
    }
    
    mutating func loadPlots(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        self.plots = try decoder.decode([Plot].self, from: data)
    }
}


// Character 结构体
struct Character: Identifiable, Codable {
    var id = UUID()
    var name: String
    var characlass: String
    var introduction: String
    var hobby: String
    var personality: String
    var ability: String
    var classnum: Int
    var persontype: Int
    var maincharacter: Bool
    var sex: Bool
}

// Characters 结构体
struct Characters: Codable {
    var characters: [Character] = []
    
    // 从 UserDefaults 加载 Characters
    static func load() -> Characters {
        if let data = UserDefaults.standard.data(forKey: "characters"),
           let characters = try? JSONDecoder().decode(Characters.self, from: data) {
            return characters
        } else {
            return Characters()
        }
    }
    
    // 将 Characters 保存到 UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "characters")
        }
    }
}

// Story 结构体
struct Story: Identifiable, Codable {
    var id = UUID()
    var title: String
    var characters: Characters
    var scene : String
    var plots : Plots
    var plot1: String
    var plot2: String
    var plot3: String
    var topic: [String] = []
    var storyintro: String
    var imagedescribe: [String] = []
    var storyimage: [URL] = []
    var main_image: URL = URL(string: "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/OtherImage/mianimage.png")!
    var finished: Bool
    var allcharacterUrls: [URL]
    var allcharacters: [String]
    
 
    // 找到 maincharacter 为 true 的 Character 并返回索引
    func mainCharacterIndex() -> Int? {
        return characters.characters.firstIndex { $0.maincharacter }
    }
    
    // 返回坏人和好人的索引
    func findCharacterIndices() -> (badpersonIndices: [Int], goodpersonIndices: [Int]) {
        let badpersonIndices = characters.characters.indices.filter { characters.characters[$0].persontype == 1 }
        let goodpersonIndices = characters.characters.indices.filter { characters.characters[$0].persontype == 0 }
        return (badpersonIndices, goodpersonIndices)
    }
}

// Stories 结构体
struct Stories: Codable {
    var bucketName = "fc-sd-62aafe39g"
    var endpoint = "oss-cn-hangzhou.aliyuncs.com"
    var stories: [Story] = []
    
    // 从 UserDefaults 加载 Stories
    static func load() -> Stories {
        if let data = UserDefaults.standard.data(forKey: "stories"),
           let stories = try? JSONDecoder().decode(Stories.self, from: data) {
            return stories
        } else {
            return Stories()
        }
    }
    
    // 将 Stories 保存到 UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "stories")
        }
    }
    func encodeStoriesToData(stories: Stories) -> Data? {
        return try? JSONEncoder().encode(stories)
    }

    func uploadStoriesToOSS(stories: Stories,objectKey: String) {
        guard let data = encodeStoriesToData(stories: stories) else {
            print("Failed to encode stories")
            return
        }
        
        let url = URL(string: "https://\(bucketName).\(endpoint)/\(objectKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Upload failed: \(error)")
                } else {
                    print("Upload succeeded")
                }
            }
        }
        
        task.resume()
    }
    func downloadStoriesFromOSS(objectKey: String, completion: @escaping (Stories?) -> Void) {
        let url = URL(string: "https://\(bucketName).\(endpoint)/\(objectKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Download failed: \(error)")
                    completion(nil)
                } else if let data = data {
                    let stories = decodeStoriesFromData(data: data)
                    completion(stories)
                }
            }
        }
        
        task.resume()
    }
    func decodeStoriesFromData(data: Data) -> Stories? {
        return try? JSONDecoder().decode(Stories.self, from: data)
    }

}

