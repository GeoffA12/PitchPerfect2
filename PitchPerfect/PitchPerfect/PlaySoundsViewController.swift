//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Geoff Arroyo  on 6/1/19.
//  Copyright © 2019 Geoff Arroyo . All rights reserved.
//

import UIKit
// Import needed for AVAudioFile on line 25, 26, 27.
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    // 6 IB Outlets for the Playback buttons, and for the stop button.
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var highPitchButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var lowPitchButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // Properties and an enumeration that will be used by our class extension
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    // MARK: - Enumerated values for UIButton tags
    // This enumeration contains values like slow and fast which map to UIButtons
    // on the PlaySoundsViewController. The values are mapped to integer values which
    // we modified on the inpsector panel within the main.storyboard file. Slow maps to 0,
    // fast maps to 1, chipmunk to 2, and so on. This enumeration gives us the ability to map
    // the tag value to the enumerated value.
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    // MARK: - Switch statement which calls playSound func based on input
    // Two IBAction functions. The playSounds function will handle six playback buttons,
    // while the stopButtonPressed function will handle the stop Button.
    // This function will convert the button's tag to a button type first. Then, using
    // the button type, we can play a sound appropriately.
    @IBAction func playSoundForButton(_ sender: UIButton) {
        // This code will convert a button's tag to a button's type.
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        configureUI(.playing)
    }
    
    // MARK: - Call stopAudio() once stop button is pressed
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        // Add a call to the stopAudio() function so that we can stop the playback when
        // we want to.
        stopAudio()
    }
    
    // MARK: - Set up View for PlaySoundsViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setupAudio() so that the AVAudioEngine is properly setup.
        setupAudio()
    }
    
    //MARK: - Call viewWillAppear() from parent class, set up configuireUI()
    // Configure the UI on the PlaySoundsViewController so that the stop button is disabled
    // once the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
        slowButton.contentMode = .center
        slowButton.imageView?.contentMode = .scaleAspectFit
        fastButton.contentMode = .center
        fastButton.imageView?.contentMode = .scaleAspectFit
        highPitchButton.contentMode = .center
        highPitchButton.imageView?.contentMode = .scaleAspectFit
        lowPitchButton.contentMode = .center
        lowPitchButton.imageView?.contentMode = .scaleAspectFit
        echoButton.contentMode = .center
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.contentMode = .center
        reverbButton.imageView?.contentMode = .scaleAspectFit
    }


}
