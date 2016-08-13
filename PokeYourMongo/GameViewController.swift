//
//  GameViewController.swift
//  PokeYourMongo
//
//  Created by Floater on 8/5/16.
//  Copyright (c) 2016 WomenWhoCode. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var gameView: UIView!
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var gameScene: GameScene?
    var paused = false
    
    //MARK: - AVFoundation Configuration
    
    private let avCaptureSession: AVCaptureSession = AVCaptureSession()
    
    lazy private var previewLayer: AVCaptureVideoPreviewLayer = { [unowned self] in
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        return previewLayer
        }()
    
    private enum AVFoundationError: ErrorType {
        case ConfigurationFailed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // We need to ask the user for permission to use the camera.
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            print("Authorized")
            self.displayCameraView()
            break
        case .Denied:
            print("Denied")
        case .NotDetermined:
            print("Ask for permission")
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                
                if granted {
                    print("Show camera view")
                    self.displayCameraView()
                } else {
                    print("Denied")
                }
            }
        case .Restricted:
            // The MDM profile installed doesn't have access to the camera. Nothing we can do here.
            print("No camera access")
        }

        gameScene = GameScene(fileNamed:"GameScene")
        if let gameScene = gameScene {
            
            // Configure the view.
            let skView = self.gameView as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.allowsTransparency = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .Fill
            
            skView.presentScene(gameScene)
        }
    }

    // MARK: Scanning
    func displayCameraView() {
        
        guard AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized else {
            return
        }
        
        // configure AV Capture Session
        do {
            let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            
            let videoInput: AVCaptureDeviceInput
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if avCaptureSession.canAddInput(videoInput) {
                avCaptureSession.addInput(videoInput)
            } else {
                throw AVFoundationError.ConfigurationFailed
            }
            
        } catch {
            debugPrint("Something went wrong")
            debugPrint(error)
            return
        }
        
        previewLayer.frame = cameraView.bounds
        if let videoPreviewView = cameraView {
            videoPreviewView.layer.addSublayer(previewLayer)
        }
        
        if avCaptureSession.running == false {
            avCaptureSession.startRunning()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func menuButtonTapped() {
        print("Pause")
        paused = !paused
        
        if paused {
            gameScene?.pauseGamePlay()
            menuButton.title = "Start"
        } else {
            gameScene?.startGamePlay()
            menuButton.title = "Pause"
        }
    }
}
