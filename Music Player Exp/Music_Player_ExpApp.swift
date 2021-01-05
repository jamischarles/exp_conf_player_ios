//
//  Music_Player_ExpApp.swift
//  Music Player Exp
//
//  Created by Jamis Charles on 12/13/20.
//

import SwiftUI
import AVFoundation
import MediaPlayer

@main
struct Music_Player_ExpApp: App {
    // delete when I don't use the delegate...
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // top level view...
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
//    struct AppView: View {
//        var body: some Scene {
//            TabView {
//                ContentView()
//                    .tabItem {
//                        Image(systemName: "list.dash")
//                        Text("Menu")
//                    }
//
////                OrderView()
////                    .tabItem {
////                        Image(systemName: "square.and.pencil")
////                        Text("Order")
////                    }
//            }
//        }
    
    // TODO: move this to another file...
//    var body: some View {
//            List(disciplines, id: \.self) { discipline in
//              Text(discipline)
//            }
//        }
//    }
}

// from https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-an-appdelegate-to-a-swiftui-app
// is this helping at all? I'm not using it currently...
// Do you need an app delegate? What does it even do?!?
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        
        // https://medium.com/@quangtqag/background-audio-player-sync-control-center-516243c2cdd1
        // set up shared audio session so it'll keep playing after minimizing app
        // it seems crucial that it's added here instead of in the other file...
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // is this mode thing the key to having it work on the lock screen? What does this even do?
            // this line is crucial for having the play/pause button on lock screen / media center work
            // I assume that's because we've set the category properly via this step...
            // TODO read about modes: https://www.raywenderlich.com/5817-background-modes-tutorial-getting-started#toc-anchor-001
            
            
            // spokenAudio = pause audio when maps or other things interrupt.
            // FIXME: doesn't restart after being interrupted... :(
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.spokenAudio)
//            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        
        
//        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        //                print("Playback ok")
        //                try AVAudioSession.sharedInstance().setActive(true)

        // signify that we should
        // FIXME: this doesn't make a difference?
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // Q: Should this be run from here or in the other file where I have it now?
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//
//        }catch let error {
//            print("Error: \(error.localizedDescription)")
//        }
        
   
        return true
    }
    
//    func setupRemoteTransportControls() {
//            // Get the shared MPRemoteCommandCenter
//            let commandCenter = MPRemoteCommandCenter.shared() // media player...
//
//            // Add handler for Play Command
//            commandCenter.playCommand.addTarget { [unowned self] event in
//                if self.player.rate == 0.0 {
//                    self.player.play()
//                    return .success
//                }
//                return .commandFailed
//            }
//
//            // Add handler for Pause Command
//            commandCenter.pauseCommand.addTarget { [unowned self] event in
//                if self.player.rate == 1.0 {
//                    self.player.pause()
//                    return .success
//                }
//                return .commandFailed
//            }
//        }
}
