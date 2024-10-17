//
//  WeavePlayApp.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/7/13.
//

import SwiftUI

@main
struct WeavePlayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var timerManager = TimerManager()
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @StateObject private var globalSettings = GlobalSettings()
    init() {
        let segmentedControlAppearance = UISegmentedControl.appearance()
        segmentedControlAppearance.selectedSegmentTintColor = UIColor.main // 设置选中部分的背景颜色
        segmentedControlAppearance.backgroundColor = UIColor.white // 设置未选中部分的背景颜色
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white // 设置选中部分的文字颜色
        ]
        segmentedControlAppearance.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray // 设置未选中部分的文字颜色
        ]
        segmentedControlAppearance.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        // 设置圆角
        segmentedControlAppearance.layer.cornerRadius = 60
        segmentedControlAppearance.layer.masksToBounds = true
    }
    
    
    
    var body: some Scene {
        
        WindowGroup {
            if authManager.isLoggedIn{
                HomeView()
                    .environmentObject(timerManager)
                    .environmentObject(globalSettings)
            }else{
                LoginView()
                    .onAppear {
                        if isFirstLaunch {
                            var appStorageArray = AppStorageArray<Bool>(key: "titlesUnlocked", defaultValue: Array(repeating: false, count: 8))
                            var titlesUnlocked = appStorageArray.wrappedValue
                            if !titlesUnlocked.isEmpty {
                                titlesUnlocked[0] = true
                                appStorageArray.wrappedValue = titlesUnlocked
                            }
                            isFirstLaunch = false
                        }
                    }
                    .environmentObject(authManager)
                    .environmentObject(timerManager)
                    .environmentObject(globalSettings)
            }
        }
    }
}

final class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private let phoneNumberKey = "savedPhoneNumber"
    private let passwordKey = "savedPassword"
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        let savedPhoneNumber = UserDefaults.standard.string(forKey: phoneNumberKey)
        let savedPassword = UserDefaults.standard.string(forKey: passwordKey)
        
        if savedPhoneNumber != nil && savedPassword != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    func login(phoneNumber: String, password: String) {
        let savedPhoneNumber = UserDefaults.standard.string(forKey: phoneNumberKey) ?? ""
        let savedPassword = UserDefaults.standard.string(forKey: passwordKey) ?? ""
        
        if phoneNumber == savedPhoneNumber && password == savedPassword {
            isLoggedIn = true
        } else {
            // 处理登录失败的情况
        }
    }
    
    func saveCredentials(phoneNumber: String, password: String) {
        UserDefaults.standard.set(phoneNumber, forKey: phoneNumberKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: phoneNumberKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        isLoggedIn = false
    }
    
    func getCredentials() -> (phoneNumber: String?, password: String?) {
        let phoneNumber = UserDefaults.standard.string(forKey: phoneNumberKey)
        let password = UserDefaults.standard.string(forKey: passwordKey)
        return (phoneNumber, password)
    }

    // 新增的函数，用于清除手机号和密码
    func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: phoneNumberKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        isLoggedIn = false
    }
}

