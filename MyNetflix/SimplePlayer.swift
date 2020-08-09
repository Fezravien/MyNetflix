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
    // 애플리케이션에서 인스턴스를 하나만 만들어 사용하기 위한 패턴
    // - 메모리 낭비를 방지한다.
    // - 다른 클래스의 인스턴스들이 데이터를 공유하기 쉽다.
    // - 두 번째 이용시부터는 객체 로딩 시간이 현저하게 줄어 성능이 좋아진다.

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
