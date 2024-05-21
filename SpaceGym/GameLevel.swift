//
//  GameLevel.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import Foundation

class GameManager {
    static let shared = GameManager()
    private init() { }
    
    var currentLevel: Int {
        get {
            let level = UserDefaults.standard.integer(forKey: "currentLevel")
            return level == 0 ? 1 : level
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentLevel")
        }
    }
    
    func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore{
            clearLevelData()
        }
    }
    
    private func clearLevelData() {
        UserDefaults.standard.removeObject(forKey: "currentLevel")
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
    }
}
