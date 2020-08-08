//
//  SimplePlayer.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/08/02.
//  Copyright © 2020 pazravien. All rights reserved.
//

import AVFoundation

class SimplePlayer {
    // 싱글톤 만들기, 왜 만드는가?
    // 클래스의 인스턴스가 딱 하나만 존재할 때 이 인스턴스로의 접근을 쉽게 할 수 있도록 만들어주는 방법
    
    static let shared = SimplePlayer()
    
    private let player = AVPlayer()
    
    var currentTime: Double {
        // currentTime 구하기
        return player.currentItem?.currentTime().seconds ?? 0
    }
    
    var totalDurationTime: Double {
        // totalDurationTime 구하기
        return player.currentItem?.duration.seconds ?? 0
    }
    
    var isPlaying: Bool {
        // isPlaying 구하기
        return player.isPlaying
    }
    
    var currentItem: AVPlayerItem? {
        // currentItem 구하기
        return player.currentItem
    }
    
    init() { }
    
    func playerViewPlayer(_ play:PlayerView) {
        play.player = self.player
    }
    
    func reset(_ play: PlayerView) {
        pause()
        //play.layer.sublayers = nil
        play.player = nil
        replaceCurrentItem(with: nil)
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func seek(to time:CMTime) {
        player.seek(to: time)
    }
    
    func replaceCurrentItem(with item: AVPlayerItem?) {
        player.replaceCurrentItem(with: item)
    }
    
    func addPeriodicTimeObserver(forInterval: CMTime, queue: DispatchQueue?, using: @escaping (CMTime) -> Void) {
        player.addPeriodicTimeObserver(forInterval: forInterval, queue: queue, using: using)
    }
   
}
