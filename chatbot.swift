import SwiftUI
import Combine

class ChatBot: ObservableObject {
    @Published var generating = false
    @Published var nowgen: String = ""
    var currentCharacterId: UUID?
    var selectedStory: UUID?

    var openAIServer: OpenAIServer!
    
    init() {
        self.openAIServer = OpenAIServer(chatBot: self)
    }
    
    func answer(_ text: String, for characterId: UUID, modelName: String = "gpt-4o-mini", completion: @escaping (Result<String, Error>) -> Void) {
        self.generating = true
        self.currentCharacterId = characterId
        
        // Get answer from OPENAI
        Task {
            let messageBody = MessageBody(model: modelName, messages: [Message(role: "user", content: text)]) // 使用传入的模型名称
            let encoder = JSONEncoder()
            guard let httpBodyData = try? encoder.encode(messageBody) else {
                await MainActor.run {
                    self.generating = false
                    completion(.failure(NSError(domain: "EncodingError", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let resp = try await self.openAIServer.getAnswer(messagesBody: httpBodyData)
               
                guard let responsedJSON = try? JSONSerialization.jsonObject(with: resp.data(using: .utf8)!) as? [String: Any] else {
                    await MainActor.run {
                        self.generating = false
                        completion(.failure(NSError(domain: "ResponseError", code: -1, userInfo: nil)))
                    }
                    return
                }
                
                guard let choice = (responsedJSON["choices"] as? [[String: Any]])?.first,
                      let message = choice["message"] as? [String: String],
                      var content = message["content"] else {
                    await MainActor.run {
                        self.generating = false
                        completion(.failure(NSError(domain: "MessageError", code: -1, userInfo: nil)))
                    }
                    return
                }
                
                while content.hasPrefix("\n") {
                    content = String(content[content.index(after: content.startIndex)...])
                }
                
                let finalContent = content
                
                await MainActor.run {
                    self.nowgen = finalContent
                    self.generating = false
                    completion(.success(finalContent))
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                await MainActor.run {
                    self.generating = false
                    completion(.failure(error))
                }
            }
        }
    }

    struct RequestError: Error, LocalizedError {
        private var error: String
        init(_ error: String) {
            self.error = error
        }
        
        var errorDescription: String? {
            error
        }
    }
}


struct MessageBody: Codable {
    var model: String
    var messages: [Message]
}

struct Message: Codable {
    var role: String
    var content: String
}
