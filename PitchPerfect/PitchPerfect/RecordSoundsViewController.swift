//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Geoff Arroyo  on 5/18/19.
//  Copyright © 2019 Geoff Arroyo . All rights reserved.
//

import UIKit
// AV foundation framework contains the AVAudioRecorder class, so we need to import it.
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    // This property set gives this view controller the ability to use and reference
    // the audio recorder in multiple places, such as stopping or beginning recording.
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // This function is called right before the View loads onto the Interface
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear was called")
        stopRecordingButton.isEnabled = false;
    }

    @IBAction func recordFunction(_ sender: Any) {
        recordingLabel.text = "Recording in progress"
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        
        // This line grabs the application's document directory, stores it within a string in the dirPath constant.
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        // File name constant
        let recordingName = "recordAudio.wav"
        // Next two lines combine the diretory path and the recording name to create
        // a full path to our file.
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator:"/"))
        
        // Audio session instance is set up. AN AVVideoAudio session is needed to either
        // record or play back audio. The AVVideoSession class is basically an abstraction
        // over the entire audio hardware set for a device. Because there's only one
        // audio hardware set for a device, we only have one instance of AVAudioSession.
        // This is also why we use .sharedInstance(), it's the shared AVAudioSession instance
        // across all apps on the device.
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        // Try statement indicates that this won't handle any errors if the line of code
        // faults.
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tap to record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // We can use the audioRecorderDidFinishRecording function from the AVAudioRecorder
    // class because we set this view controller as a delegate of the AVAudioRecorder class.
    // Therefore, our view controller conforms and we can use different audio functions in
    // this view controller.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // This line will call the stopRecording segway and send to it the path where
        // the recorded file is located. The flag indicates whether the recorded path
        // was successfully sent to the playback view controller.
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }
        else {
            print("Recording wasn't successful.")
        }
    }
    
    // Function called on the existing view controller to help it prepare for the segue. 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if this is the segue that we want. It needs to be the stopRecordingSegue
        // that we set up in the storyboard.
        if segue.identifier == "stopRecording" {
            // Grab the viewcontroller that we're going to, or the destination. We can
            // use the .destination property and a forced upcast to the PlaySoundsViewController to accomplish this.
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            // Grab the sender, which is the recordedAudioURL. We can see that the URL is
            // the sender on line 82 in the performSegue function.
            let recordedAudioURL = sender as! URL
            // Set the recordedAudio URL in the PlaySoundsViewController.
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
}

