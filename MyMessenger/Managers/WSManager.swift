//
//  WSManager.swift
//  MyMessenger
//
//  Created by Danil Antonov on 30.01.2024.
//

import Foundation

class WSManager {
    static let shared = WSManager()
    private init() { }
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "ws://127.0.0.1:6001/app/2152cf703eef4f4caa3d?protocol=7&client=js&version=8.4.0-rc2&flash=false")!)
    
    public func subscribeBtcUsd(currentUserId: Int, userId: Int) {
        let channel = currentUserId < userId ? "dialog_\(currentUserId)_\(userId)" : "dialog_\(userId)_\(currentUserId)"
        let message = URLSessionWebSocketTask.Message.string("{\"event\":\"pusher:subscribe\", \"data\": {\"auth\": \"\", \"channel\": \"\(channel)\"}}")
        self.webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    public func unSubscribeBtcUsd() {
        let message = URLSessionWebSocketTask.Message.string("UNSUBSCRIBE: ОТ_ЧЕГО_ОТПИСЫВАЕМСЯ ")
        WSManager.shared.webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    public func connectToWebSocket() {
        WSManager.shared.webSocketTask.resume()
        self.receiveData() { }
    }

    func receiveData(completion: @escaping () -> Void) {
        WSManager.shared.webSocketTask.receive { result in
            switch result {
                case .failure(let error):
                    print("Error in receiving message: \(error)")
                case .success(let message):
                    switch message {
                        case .string(var text):
                            text = self.getClearTextAnswer(text: text)
                            let dataMessage = text.data(using: .utf8)!
                            let realMessageModel = try! JSONDecoder().decode(RealMessageModel.self, from: dataMessage)
                        
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessage"), object: realMessageModel)
                            print("✉️ New message in chat: \(realMessageModel)")
                        case .data(let data):
                            print("Received data: \(data)")
                        @unknown default:
                            debugPrint("Unknown message")
                    }
                self.receiveData() { }
            }
        }
    }
    
    func getClearTextAnswer(text: String) -> String {
        var text = text
        text = text.filter { $0 != "\\"}
        text = text.replacingOccurrences(of: "\"{", with: "{")
        text = text.replacingOccurrences(of: "}\"}", with: "}}")
        
        return text
    }
}
