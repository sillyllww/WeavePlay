import SwiftUI

actor OpenAIServer {
    @AppStorage("api_key") private var APIKEY = "sk-HlCAlN9LDbK5a3aw5f63017eFc7f4a0dA82a290bE67a8d96"
    unowned let chatBot: ChatBot
    
    init(chatBot: ChatBot) {
        self.chatBot = chatBot
    }
    
    nonisolated func getAnswer(messagesBody: Data) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.mjdjourney.cn/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(await APIKEY)",
            "Content-Type": "application/json"
        ]
        request.httpBody = messagesBody
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8)!
            .replacingOccurrences(of: "\\\\n", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\r", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\t", with: "@@@@@")
    }
}
