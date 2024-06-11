//
//  GameCenterManager.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 11.06.2024.
//

import GameKit

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    @Published var isAuthenticated: Bool = false

    override init() {
        super.init()
        authenticateLocalPlayer()
    }

    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local

        localPlayer.authenticateHandler = { [weak self] (viewController, error) in
            guard let self else { return }
            if let vc = viewController {
                UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                isAuthenticated = true
            } else {
                isAuthenticated = false
                print(error?.localizedDescription ?? "Game Center authentication failed")
            }
        }
    }

    func showLeaderboard(leaderboardID: String = "com.bkoc.GameGuessr.Scores") {
        let viewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = self

        if let rootVC = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first?.rootViewController {
            rootVC.present(viewController, animated: true, completion: nil)
        }
    }

    func reportScore(score: Int, leaderboardID: String = "com.bkoc.GameGuessr.Scores") {
        let lbScore = GKLeaderboardScore()
        lbScore.leaderboardID = leaderboardID
        lbScore.player = GKLocalPlayer.local
        lbScore.value = score

        GKLeaderboard.submitScore(lbScore.value, context: 0, player: lbScore.player, leaderboardIDs: [lbScore.leaderboardID]) { (error) in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score reported successfully!")
            }
        }
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
