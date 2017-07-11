//
//  ViewController.swift
//  Watson Speaks
//
//  Created by Christopher Aziz on 7/10/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import SpeechToTextV1
import LanguageTranslatorV2

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var language = "es"
    var translation = ""
    var hasTranslated = false
    var isRecording = false
    var isStreaming = false
    var speechToText: SpeechToText?
    
    // MARK: - Outlets
    
    @IBOutlet weak var watsonButton: UIButton!
    @IBOutlet weak var transcribedLabel: UITextView!
    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func updateTranslation(_ sender: Any) {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.language = "es"
        case 1:
            self.language = "fr"
        case 2:
            self.language = "it"
        case 3:
            self.language = "ar"
        default:
            break
        }
        self.translate()
    }
    
    // MARK: - On View Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechToText = SpeechToText(username: Constants.SpeechToText.username, password: Constants.SpeechToText.password)
        
    }
    
    // MARK: - Recording
    
    @IBAction func startstopRecording(_ sender: Any) {
        if isRecording {
            watsonButton.alpha = CGFloat(1)
            stopStreaming()
            self.isRecording = false
            while(self.isStreaming) {}
            translate()
        } else {
            startStreaming()
            watsonButton.alpha = CGFloat(0.5)
            self.isRecording = true
        }
    }
    
    func startStreaming() {
        self.isStreaming = true
        var settings = RecognitionSettings(contentType: .opus)
        settings.continuous = true
        settings.interimResults = true
        let failure = { debugPrint($0) }
        speechToText?.recognizeMicrophone(settings: settings, failure: failure) { results in
            self.originalTextView.text = results.bestTranscript
        }
    }
    
    func stopStreaming() {
        speechToText?.stopRecognizeMicrophone()
        self.isStreaming = false
    }

    // MARK: - Translation
    
    func translate() {
        callTranslation(toTranslate: originalTextView.text!)
        watsonButton.isHidden = true
        segmentedControl.isEnabled = false
        while (!self.hasTranslated) {}
        self.hasTranslated = false
        watsonButton.isHidden = false
        segmentedControl.isEnabled = true
        self.transcribedLabel.text = self.translation
    }
    
    func callTranslation(toTranslate: String) {
        let languageTranslator = LanguageTranslator(username: Constants.LanguageTranslator.username, password: Constants.LanguageTranslator.password)
        let failure = { debugPrint($0) }
        languageTranslator.translate(toTranslate, from: "en", to: self.language, failure: failure) { translation in
            if !translation.translations.isEmpty {
                DispatchQueue.main.async {
                    self.transcribedLabel.text = translation.translations[0].translation
                }
                self.hasTranslated = true
            }
        }
        
    }
}

