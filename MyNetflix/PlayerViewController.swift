//
//  PlayerViewController.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/07/23.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var touchScreenCount = 0
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    let simplePlayer = SimplePlayer.shared
    
    var timeObserver: Any?
    var isSeeking: Bool = false
    
    // 해당 ViewControler가 메모리에 올라옴
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simplePlayer.playerViewPlayer(playerView)
        
        updateTime(time: CMTime.zero)
        // TODO: TimeObserver 구현
        // CMTime -- seconds, preferrendTimescale 시간과 분할 1초를 10개로 -> 0.1초
        // DispatchQueue.main -- 0.1초마다 UIrable을 업데이트 시킬것인데 main 쓰레드에게 0.1초마다 알려주겠다
        
        timeObserver = simplePlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: DispatchQueue.main, using: { time in
            self.updateTime(time: time)
        })
    }

    @IBAction func beginDrag(_ sender: UISlider) {
        isSeeking = true
    }
    
    @IBAction func endDrag(_ sender: UISlider) {
        isSeeking = false
    }
    
    
    @IBAction func seek(_ sender: UISlider) {
        // TODO: 시킹 구현
        guard let currentItem = simplePlayer.currentItem else {
            return
        }
        // sender.value로 어느 위치에 슬라이더가 위치하는지
        let position = Double(sender.value) // 0 ... 1
        
        // 재생 지점 찾기
        let seconds = position * currentItem.duration.seconds // .seconds -- double로
        
        // CMTime 으로 바꾸기
        let time = CMTime(seconds: seconds, preferredTimescale: 100) // 31.322332332 나오니까 31.32 까지
                
            simplePlayer.seek(to: time)
    }
    
    func updateTime(time: CMTime) {
        // print(time.seconds)
    
        // currentTime label, totalduration label, slider
        
        // TODO: 시간정보 업데이트, 심플플레이어 이용해서 수정
        currentTimeLabel.text = secondsToString(sec: simplePlayer.currentTime)   // 3.1234 >> 00:03
        totalDurationLabel.text = secondsToString(sec: simplePlayer.totalDurationTime)  // 39.2045  >> 00:39
        
        if isSeeking == false {
            // 노래 들으면서 시킹하면, 자꾸 슬라이더가 업데이트 됨, 따라서 시킹아닐때마 슬라이더 업데이트하자
            // TODO: 슬라이더 정보 업데이트
            timeSlider.value = Float(simplePlayer.currentTime/simplePlayer.totalDurationTime)
        }
    }
    
    func secondsToString(sec: Double) -> String {
        guard sec.isNaN == false else { return "00:00" }
        let totalSeconds = Int(sec)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
    
    // 한쪽으로 고정 (강제)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    
    
    // 실제로 보여지기 직전에
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simplePlayer.play()
        ControllButtonVisible()
    }
    
    
    @IBAction func togglePlaybutton(_ sender: Any) {
        if simplePlayer.isPlaying {
            simplePlayer.pause()
            updatePlayButton()
        } else {
            simplePlayer.play()
            updatePlayButton()
        }
    }
        

    @IBAction func closeButtonTapped(_ sender: Any) {
        simplePlayer.reset()
        dismiss(animated: true, completion: nil)
    }
    
    func updatePlayButton() {
        // TODO: 플레이버튼 업데이트 UI작업 > 재생/멈춤
        if simplePlayer.isPlaying {
            playButton.isSelected = true
        } else {
            playButton.isSelected = false
        }
    }
    
    @IBAction func touchScreen(_ sender: Any) {
        if touchScreenCount == 0 {
            ControllButtonDisVisible()
            touchScreenCount += 1
        } else {
            ControllButtonVisible()
            touchScreenCount -= 1 
        }
    }
    
    func ControllButtonVisible(){
        playButton.isSelected = true
        playButton.isHidden = true
        closeButton.isHidden = true
        timeSlider.isHidden = true
        currentTimeLabel.isHidden = true
        totalDurationLabel.isHidden = true
    }
    
    func ControllButtonDisVisible(){
        playButton.isSelected = false
        playButton.isHidden = false
        closeButton.isHidden = false
        timeSlider.isHidden = false
        currentTimeLabel.isHidden = false
        totalDurationLabel.isHidden = false
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        guard self.currentItem != nil else { return false }
        return self.rate != 0
    }
}


