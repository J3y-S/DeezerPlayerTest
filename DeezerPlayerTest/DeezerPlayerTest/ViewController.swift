//
//  ViewController.swift
//  DeezerPlayerTest
//
//  Created by Jerome Schmitz on 13.09.17.
//  Copyright © 2017 mubo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userStateLabel: UILabel!
    @IBOutlet weak var currentlyPlayingLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var deezerConnect: DeezerConnect!
    var player: DZRPlayer!
    var manager: DZRRequestManager!
    var trackRequest: DZRCancelable?
    
    var trackIds: [String] = ["2520229", "119872484", "119872506", "119872558"]
    var nextPlayingTrackIndex = 0
    var playingTrack: DZRTrack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deezerConnect = DeezerConnect(appId: "252182", andDelegate: self)
        DZRRequestManager.default().dzrConnect = deezerConnect
        
        self.player = DZRPlayer(connection: deezerConnect)
        self.player.networkType = .wifiAnd3G
        self.player.delegate = self
        self.manager = DZRRequestManager.default().sub()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deezerPlayerDidStop), name: NSNotification.Name.DZRAudioPlayerDidStopPlaying, object: nil)
        
        updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ConnectButtonTapped(_ sender: UIBarButtonItem) {
        deezerConnect.authorize([DeezerConnectPermissionOfflineAccess])
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        playNextTrack()
    }
    
    func playNextTrack() {
        let trackId = trackIds[nextPlayingTrackIndex]
        
        playTrackId(trackId: trackId)
        
        nextPlayingTrackIndex = (nextPlayingTrackIndex + 1) % trackIds.count
    }
    
    func playTrackId(trackId: String) {
        
        self.trackRequest?.cancel()
        self.player.stop()
        
        self.trackRequest = DZRTrack.object(withIdentifier: trackId, requestManager: self.manager, callback: { (track, error) in
            
            guard let track = track as? DZRTrack else {
                print("error loading track: \(error)")
                return
            }
            self.playingTrack = track
            self.updateView()
            
            self.player.play(track)
            self.player.updateRepeatMode(.none)
        })
    }
    
    func updateView() {
        userStateLabel.text = deezerConnect.isSessionValid() ? "Logged in" : "Logged out"
        playButton.isEnabled = deezerConnect.isSessionValid()
        currentlyPlayingLabel.text = playingTrack?.description ?? "None"
    }
}

extension ViewController: DeezerSessionDelegate {
    
    func deezerDidLogin() {
        updateView()
        print("deezerDidLogin")
    }
    
    func deezerDidNotLogin(_ cancelled: Bool) {
        updateView()
        print("deezerDidNotLogin")
    }
    
    func deezerDidLogout() {
        updateView()
        print("deezerDidLogout")
    }
}

extension ViewController: DZRPlayerDelegate {
    
    func deezerPlayerDidStop() {
        
        print("didStopPlaying")
        playNextTrack()
    }
    
    func player(_ player: DZRPlayer!, didStartPlaying track: DZRTrack!) {
        
        print("didStartPlaying called")
        
        if track != nil {
            print("didStartPlaying: \(track.description)")
            playingTrack = track
            updateView()
        }
    }
    
    func player(_ player: DZRPlayer!, didPlay playedBytes: Int64, outOf totalBytes: Int64) {
        
    }
    
    func player(_ player: DZRPlayer!, didBuffer bufferedBytes: Int64, outOf totalBytes: Int64) {
        
    }
    
    func playerDidPause(_ player: DZRPlayer!) {
        print("playerDidPause")
    }
    
    func player(_ player: DZRPlayer!, didEncounterError error: Error!) {
        print("didEncounterError: \(error)")
    }
}

