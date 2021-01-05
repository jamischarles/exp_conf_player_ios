//
//  ContentView.swift
//  Music Player Exp
//
//  Created by Jamis Charles on 12/13/20.
//

import SwiftUI
import AVKit // for av controls
import MediaPlayer


struct ContentView: View {
    func viewDidLoad() {
        
    }
    
    // basic list view
    let disciplines = ["statue", "mural", "plaque"]
    
    // list view to choose what to play next (
//    var body: some View {
//        List(disciplines, id: \.self) { discipline in
//          Text(discipline)
//        }
//    }
    
    // musicplayer view
    var body: some View {
        MusicPlayer().navigationTitle("Conference Player")
//        TabView {
//            ContentView()
//                .tabItem {
                    
//                }
                
            
//        }
        

    }
}

// for right hand view in xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// is this the equivalent of a view controller?
struct MusicPlayer :View {
    // force light mode

    

    // inital state?
    // anything here can then be accessed in self.*
    @State var data : Data = .init(count: 0)
    @State var title = ""
    //@State var player : AVAudioPlayer! // used for playing a local file (doesn't support streaming)
    @State var player : AVPlayer! // supports streaming a internet url
    @State var playerItem: AVPlayerItem = AVPlayerItem(url: URL(string: "Bogus")!) // bogus init value FIXME: Whish we didn't need this for duration...
    @State var isPlaying = false
    // NOTE: interesting. If I don't assign it here, it expects it to be passed in as params.
    @State var currentTime = 0
    @State var duration : Double = 0
    @State var width: CGFloat = 0
    @State var songs = ["black", "bad"]
    @State var currentSong = 0
    @State var isFinished = false
    @State var del = AVdelegate() // WHAT does this do?

    
    // Q: Does this render every cycle or on state change like react does? I think so...
    var body: some View {
        
        VStack(spacing: 10 ) {
            // FIXME: where should image live? not in folder...
            Image(uiImage: self.data.count == 0 ? UIImage(named: "elder-bednar.jpeg")! : UIImage(data: self.data)!)
                .resizable()
                .frame(width: self.data.count == 0 ? 208 : nil, height: 266)
                
                .cornerRadius(15)
            
//            MPMediaItemArtwork(boundsSize: image.size) { size in
//                return image
//            }

            // title is coming from the metadata from the file... Cool!
//            Text(self.title).font(.title).padding(.top).colorInvert()
            Text("Bear up their burdens - David A. Bednar").font(.subheadline) //font(.title)//.padding(.top)
            Text("\(getTimestringFromSeconds(seconds: self.currentTime))/\(getTimestringFromSeconds(seconds: Int(self.duration)))").font(.body)
//            Spacer() // forces a big space in here and pushes everything else

            // stack things on top of each other
            ZStack(alignment: .leading) {
                // red progress bar for song...
                Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
//                Capsule().fill(Color.red).frame(width: 200, height: 8) // fixed width
                Capsule().fill(Color.red).frame(width: self.width, height: 8)
                    .gesture(DragGesture()

                                // support for drag & drop on the red progress bar
                        .onChanged({ (value) in
                            let x = value.location.x
                            self.width = x

                        })

                        .onEnded({(value) in

                            let x = value.location.x
                            
                            let screen = UIScreen.main.bounds.width - 30
                            let percent = x  / screen
                            
                            // update current time after draf
                            // FIXME: extract into function
                            self.currentTime = Int(Double(percent) * self.duration)
                            
                            let time = CMTime(value: Int64(self.currentTime), timescale: 1)
                            
                            self.player.seek(to: time  )
                        }))

            }
            .padding(.top)

            HStack(spacing: UIScreen.main.bounds.width / 5 - 30){
                Button(action: {
                    if self.currentSong > 0 {
                        self.currentSong -= 1
                        self.changeSongs()
                    }
                }) {
                    Image(systemName: "backward.fill").font(.title)
                }.colorInvert()

                Button(action: {
                    seekBackward(seconds: 15)
                    
                    
//                    player.seek(to: time)
                    
//                    self.player.currentTime -= 15
//                    self.player.currentTime() -= 15

//                    let decrease = self.player.currentTime - 15
//
//                    // if -15s would go beyond start of total time, go to start
//                    if decrease < 0 {
//                        self.player.currentTime = decrease
//                    }
                }) {
                    Image(systemName: "gobackward.15").font(.title)
                }.colorInvert() // turn it white. FIXME make it work in dark / white mode... Or disable dark mode...

                Button(action: {
                    let isPlaying = getPlayerStatus()
                    if isPlaying {
                        pause()
//                        self.isPlaying = false
                    } else {
                        play()
//                        self.isPlaying = true
                    }
//                    if self.player.
//                    if self.player.isPlaying {
//                        self.player.pause()
//                    }
//                    if self.player.isPlaying {
//                        self.player.pause()
//                        self.isPlaying = false
//                    } else {
//                        if self.isFinished {
////                            self.player.currentTime = 0
//                            self.width = 0
//                            self.isFinished = false
//                        }
//
//                        self.player.play() // plays the music
//                        self.isPlaying = true
//                    }


                }) {
                    let isPlaying = getPlayerStatus()
                    Image(systemName: isPlaying && !self.isFinished ? "pause.fill" : "play.fill").font(.title)
                }.colorInvert()

                Button(action: {
                    seekForward(seconds: 30)
//                    let increase = self.player.currentTime + 15
//
//                    // if +15s would go beyond end of total time, ignore
//                    if increase < self.player.duration {
//                        self.player.currentTime = increase
//                    }
                }) {
                    Image(systemName: "goforward.30").font(.title)
                }.colorInvert()

                Button(action: {
                    if self.songs.count - 1 != self.currentSong {
                        self.currentSong += 1
                        self.changeSongs()
                    }
                }) {
                    Image(systemName: "forward.fill").font(.title)
                }.colorInvert()
            }.padding(.top, 25)
            .foregroundColor(.black)
            
            
        }.padding()
        .onAppear(){
//
            // TODO try this...
            //https://stackoverflow.com/questions/34563329/how-to-play-mp3-audio-from-url-in-ios-swift

//            "https://media2.ldscdn.org/assets/general-conference/april-2014-general-conference/2014-04-4050-elder-david-a-bednar-64k-eng.mp3"
//            let url = Bundle.main.path(forResource: "black", ofType: "mp3") // hardcode what song
             // hardcode what song

            // 2) With song from internet
//            let url = Bundle.main.path(forResource: "https://media2.ldscdn.org/assets/general-conference/april-2014-general-conference/2014-04-4050-elder-david-a-bednar-64k-eng", ofType: "mp3")
            let url = URL(string: "https://media2.ldscdn.org/assets/general-conference/april-2014-general-conference/2014-04-4050-elder-david-a-bednar-64k-eng.mp3")

//            let url = URL(string: "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3")
            let playerItem = AVPlayerItem(url: url!)

            
            
            
            do {
                // media controls for lock screen?
                
                
                // set up shared audio session. (THIS ENSURES IT'll KEEP PLAYING AFTER CLOSING APP, locking screen)
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//                print("Playback ok")
//                try AVAudioSession.sharedInstance().setActive(true)
                
//                let audioSession = AVAudioSession.sharedInstance()
                
                
//                let audioPlayer = self.player.currentItem
//                    audioPlayer.volume = slider.value
//                    audioPlayer.numberOfLoops = -1
//                    audioPlayer.prepareToPlay()
//                    if(audioShouldPlay){
//                        audioPlayer.play()
                
                // ensure the lock screen has player controls on it...
//                TODO: Remove all the other code I added to see if it makes a difference
                
                // this show up in command center, and ties command center controls to what is playing...
//                FIXME: doesn't show a lot of things properly... LIke syncing pause/start controls
//                let mpic = MPNowPlayingInfoCenter.default()
//                mpic.nowPlayingInfo = [MPMediaItemPropertyTitle:"Bear up their Burdens", MPMediaItemPropertyArtist:"David A. Bednar"]
////                        }
//
//                // Q: Does this do anything? Apparently not...
//                // Q: How do I get lock screen working again?
//                let commandCenter = MPRemoteCommandCenter.shared()
////                commandCenter.nextTrackCommand.isEnabled = true
//                commandCenter.playCommand.isEnabled = true
//                commandCenter.pauseCommand.isEnabled = true

                // auto play
                self.player = AVPlayer(playerItem:playerItem)
                self.playerItem = playerItem // need this for getTrackDuration
//                    let audioPlayer = try AVAudioPlayer(contentsOf: sound)
                //self.player.prepareToPlay()
                self.player.play()
                self.isPlaying = true
                }catch let error {
                    print("Error: \(error.localizedDescription)")
                }

            
            setupRemoteTransportControls()
            setupNowPlaying()
            
//            setupNowPlaying()
//            setupRemoteTransportControls()
//            commandCenterSetup()
            
            // 1) normal way that works with local file
//            let url = Bundle.main.path(forResource: self.songs[self.currentSong], ofType: "mp3")
//            self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))


//            self.player.delegate = self.del

//            self.player.prepareToPlay() // not working... is it a CPU issue?
            // TODO: restart and try again...
            self.getData()
            
            // these both work
//            let duration = Double(playerItem.asset.duration.value) / Double(playerItem.asset.duration.timescale)
//            let duration = self.player.currentItem?.duration.seconds
            
//            let duration = Double(self.player.currentItem?.duration.value) / Double(self.player.currentItem?.duration.timescale)
//            let duration = self.player.currentItem?.currentTime()
            
//            let duration2 = self.player.currentItem?.duration.value
            
            // only one that works...
//            let duration = Double(playerItem.asset.duration.value) / Double(playerItem.asset.duration.timescale)
            let duration = getTrackDuration()
            self.duration = duration
    
            
            // is this the only way to get currentTime with a avplayer streaming thing?
            // adds a periodic observer...
            self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
                // FIXME: move this to other function?
                // Q: What is the status? when this doesn't work
                if self.player!.currentItem?.status == .readyToPlay {
//                    print("is ready to play, increment")
                    let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                    self.currentTime = Int(currentTime)
                    
//                    let secs = Int(currentTime)
                    
                    let screen = UIScreen.main.bounds.width - 30
                    //
                    let value = currentTime / duration
                    
                    
                    // starts width at 0 (for red pill progress) (see state)
                    // then every second increase based on value (% completion)
                    self.width = screen * CGFloat(value)
                    
                    //                        self.timeLabel.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String//"\(secs/60):\(secs%60)"
                    //                        print("currentTime", currentTime)
                }
                
            })

            // this is like setTimout? Every second print the current time?
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
//                print("duration", duration)
//                print("duration2", duration2)
//                print("duration3", duration3)
//                if self.isPlaying {
////                if self.player.isPlaying { // FIXME: why didn't this work?
//                    let screen = UIScreen.main.bounds.width - 30
////
////                    let value = self.player.currentTime / self.player.duration
////                    let value = Double(self.player.currentTime()) / duration
////
////                    // starts width at 0 (for red pill progress) (see state)
////                    // then every second increase based on value (% completion)
////                    self.width = screen * CGFloat(value)
//////                    print(self.player.currentTime)
//                }
//            }

            // listen for the "Finish" custom event
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in

                self.isFinished = true
            }
            
            // listen for interruptions
//            NotificationCenter.default.addObserver(name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
            NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { (notification: Notification) in
                print("INTERRUPTED", notification)
                
                
                
                
                // TODO check for cases
                
                guard let userInfo = notification.userInfo,
                        let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                        let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                            return
                    }
                
                print("type", type)
                print("typeValue", typeValue)
                
                if (type == .began) {
                    print("## INTERRUPT BEGAN")
                } else if (type == .ended) {
                    print("## INTERRUPT ENDED")
                    // start playing again after rewinding by 5 seconds
                    // rewind by 5 seconds... TODO: make this a function?
                    seekBackward(seconds: 5)
                    play()
                    
                }
                
            }
            
        }
    }
    
    func getTimestringFromSeconds(seconds: Int) ->String {
        let min = String(format: "%02d", seconds / 60) // pad with zeros https://stackoverflow.com/questions/25566581/leading-zeros-for-int-in-swift
        let sec = String(format: "%02d", seconds % 60)
        
        return "\(min):\(sec)"
    }
    
    func handleInterruption() {
        
    }

    func getData() {

//        let asset = AVAsset(url: self.player.url!)
//        // I think this is where the metadata is being processed...
//        for i in asset.commonMetadata {
//            if i.commonKey?.rawValue == "artwork" {
//                let data = i.value as! Data
//                self.data = data
//            }
//
//            if i.commonKey?.rawValue == "title" {
//                let title = i.value as! String
//                self.title = title
//            }
//
//        }

    }

    func changeSongs() {
//        let url = Bundle.main.path(forResource: self.songs[self.currentSong], ofType: "mp3")
//        self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
//
//        self.player.delegate = self.del
//
//        self.data = .init(count:0)
//        self.title = ""
//        self.player.prepareToPlay()
//        self.getData()
//
//        self.isPlaying = true
//        self.isFinished = false
//
//        self.width = 0
//        self.player.play()

    }
    
    
    // THIS WORKED
//    func setupNowPlaying() {
//        // Define Now Playing Info
//        var nowPlayingInfo = [String : Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Movie"
//
//        if let image = UIImage(named: "lockscreen") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                MPMediaItemArtwork(boundsSize: image.size) { size in
//                    return image
//            }
//        }
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentItem?.currentTime().seconds
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.asset.duration.seconds
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
//
//        // Set the metadata
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
    
    // none of this works...
//    func setupRemoteTransportControls() {
//        // Get the shared MPRemoteCommandCenter
//        let commandCenter = MPRemoteCommandCenter.shared() // media player...
//
//        // Add handler for Play Command
//        commandCenter.playCommand.addTarget { [unowned self] event in
//            if self.player.rate == 0.0 {
//                self.player.play()
//                return .success
//            }
//            return .commandFailed
//        }
//
//        // Add handler for Pause Command
//        commandCenter.pauseCommand.addTarget { [unowned self] event in
//            if self.player.rate == 1.0 {
//                self.player.pause()
//                return .success
//            }
//            return .commandFailed
//        }
//    }
    
    // DOES THIS WORK?!?
//    func setupRemoteTransportControls() {
//
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        // Add handler for Play Command
//        commandCenter.playCommand.addTarget { event in
//            self.player.play()
//            return .success
//        }
//
//        // Add handler for Pause Command
//        commandCenter.pauseCommand.addTarget { event in
////            self.player.stop()
//            self.player.pause()
//            return .success
//        }
//    }
    
    // this is the stuff that worked?
//    func commandCenterSetup() {
//
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//
//       setupNowPlaying()
//
//        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//
//            print("PAUSE")
//            self.player.pause()
//            return .success
//
//           }
//
//
//           commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//
//            print("PLAY")
//            self.player.play()
//            return .success
//           }
//
//
//
//        }
    
    // WORKS? -- FROM ARTICLE
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
//        https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // not working...
//        commandCenter.seekBackwardCommand.isEnabled = true
//        commandCenter.seekForwardCommand.isEnabled = true
//        commandCenter.skipForwardCommand.isEnabled = true
        
        // change default time values (defaults to 10s)
        // this is for label only not for time
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(15)]
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(30)]
//        commandCenter.skipForwardCommand.preferredIntervals =
//        commandCenter.
        
        // Add handler for Play Command
        // FIXME: do we need unowned self? or should this be somewhere else?
        // this connects lock screen paute/play
        commandCenter.playCommand.addTarget { [ self] event in
            let isPlaying = getPlayerStatus()
            
            print("Play command - is playing: \(isPlaying)")
            if !isPlaying {
                self.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [ self] event in
            let isPlaying = getPlayerStatus()
            print("Pause command - is playing: \(isPlaying)")
            if isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.skipForwardCommand.addTarget { [ self] event in
            // pause/play is not strictly needed. What IS needed to ensure that elapsed time works after seeking in locked mode is that rate is set to 0 before seeking, and set to 1 after
//            https://medium.com/@varundudeja/showing-media-player-system-controls-on-notification-screen-in-ios-swift-4e27fbf73575
                pause()
//            let isPlaying = getPlayerStatus()
//            print("Pause command - is playing: \(isPlaying)")
//            if isPlaying {
                seekForward(seconds: 30)
                play()
                return .success
//            }
//            return .commandFailed
        }
        
        commandCenter.skipBackwardCommand.addTarget { [ self] event in
            // pause/play is not strictly needed. What IS needed to ensure that elapsed time works after seeking in locked mode is that rate is set to 0 before seeking, and set to 1 after (what we do in updateNowPlaying, which is called from pause/play)
//            https://medium.com/@varundudeja/showing-media-player-system-controls-on-notification-screen-in-ios-swift-4e27fbf73575
            
//            let isPlaying = getPlayerStatus()
//            print("Pause command - is playing: \(isPlaying)")
//            if isPlaying {
                pause()
                seekBackward(seconds: 15)
                play()
                return .success
//            }
//            return .commandFailed
        }
        
//        commandCenter.seekForwardCommand.addTarget { [ self] event in
//            let isPlaying = getPlayerStatus()
//            print("Pause command - is playing: \(isPlaying)")
//            if isPlaying {
//                self.pause()
//                return .success
//            }
//            return .commandFailed
//        }
        
//        How to change seek position from lock screen
//        commandCenter.changePlaybackPositionCommand
    }

    // runs first time
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Bear up their burdens"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "David A. Bednar"
//        nowPlayingInfo[MPMediaItemPropertyAlbum] = "LDS Playlist"

        if let image = UIImage(named: "elder-bednar.jpeg") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = getElapsedTime()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = getTrackDuration() // Duration needed so lock screen can track % progress
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func play() {
        self.player.play()
//        playPauseButton.setTitle("Pause", for: UIControl.State.normal)
        updateNowPlaying(isPause: false)
        print("Play - current time: \(String(describing: getElapsedTime())) - is playing: \(getPlayerStatus())")
    }

    func pause() {
        self.player.pause()
//        playPauseButton.setTitle("Play", for: UIControl.State.normal)
        updateNowPlaying(isPause: true)
        print("Pause - current time: \(getElapsedTime()) - is playing: \(getPlayerStatus())")
    }
    
    // TODO combine these 2 since only 1 char is different?
    // FIXME: doesn't work when paused
    // if you seek forward on lock screen, then the count stops though it keeps playing...
    func seekForward(seconds:Int) {
        //self.currentTime += seconds
        let time = CMTime(value: Int64(self.currentTime + seconds), timescale: 1)
        

//        self.player.seek(to: time)
        // example of inline fn for 2nd param...
        // seems to make no difference...
        self.player.seek(to: time) { (didSucceed) in
            print("didSucceed after Seekforward", didSucceed)
            // update statuses and timelines

            let isPlaying = getPlayerStatus()
            print("isPlaying", isPlaying)

            // updates playback rate to 1 (necessary after seeking)
            updateNowPlaying(isPause: isPlaying)
        }
        
       
    }
    
    func seekBackward(seconds:Int) {
        self.currentTime -= seconds
        let time = CMTime(value: Int64(self.currentTime), timescale: 1)
        
        self.player.seek(to: time)
        
        
        // update statuses and timelines
        let isPlaying = getPlayerStatus()
        
        // updates playback rate to 1 (necessary after seeking)
        updateNowPlaying(isPause: isPlaying)
    }
    
   
    // this is run whenever we pause / play...
    // TODO: hook this to the main buttons too...
    // and control the main buttons from here...
    func updateNowPlaying(isPause: Bool) {
        
        
        // Define Now Playing Info
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
        
        // this updates the lock screen with current info
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = getElapsedTime()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1

        // Set the metadata on the lockscreen
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // universal way to get the player status
    func getPlayerStatus() -> Bool{
        var isPlaying = false
        if self.player?.timeControlStatus == .paused {
            isPlaying = false
        } else if self.player?.timeControlStatus == .playing {
            isPlaying = true
        }
        
        
        return isPlaying
    }
    
    func getElapsedTime() -> Double {
        return CMTimeGetSeconds(self.player!.currentTime())
    }
    
    // FIXME: get this to work...
    func getTrackDuration() -> Double {
        let asset = self.playerItem.asset
        let duration = Double(asset.duration.value) / Double(asset.duration.timescale)
        return duration
    }
}

// hm... maybe i can just put the delegates here?
// overrides and callback functions?
class AVdelegate : NSObject,AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {


        // Fire the "Finish" event when the callback is called for "done"
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
    
    
}





// ##########################
// OLD CODE THAT WORKED - PLAYING LOCAL MP3 FILE
// #########################

//
//import SwiftUI
//import AVKit
//
//struct ContentView: View {
//    var body: some View {
//        NavigationView{
//            MusicPlayer().navigationTitle("Music Player")
//        }
//
//
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//struct MusicPlayer :View {
//
//    // inital state?
//    // anything here can then be accessed in self.*
//    @State var data : Data = .init(count: 0)
//    @State var title = ""
//    @State var player : AVAudioPlayer! // used for playing a local file (doesn't support streaming)
//    @State var isPlaying = false
//    @State var width: CGFloat = 0
//    @State var songs = ["black", "bad"]
//    @State var currentSong = 0
//    @State var isFinished = false
//    @State var del = AVdelegate() // WHAT does this do?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(uiImage: self.data.count == 0 ? UIImage(named: "itunes")! : UIImage(data: self.data)!)
//                .resizable()
//                .frame(width: self.data.count == 0 ? 250 : nil, height: 250)
//                .cornerRadius(15)
//
//            // title is coming from the metadata from the file... Cool!
//            Text(self.title).font(.title).padding(.top)
//
//            // stack things on top of each other
//            ZStack(alignment: .leading) {
//                // red progress bar for song...
//                Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
////                Capsule().fill(Color.red).frame(width: 200, height: 8) // fixed width
//                Capsule().fill(Color.red).frame(width: self.width, height: 8)
//                    .gesture(DragGesture()
//
//                                // support for drag & drop on the red progress bar
//                        .onChanged({ (value) in
//                            let x = value.location.x
//                            self.width = x
//
//                        })
//
//                        .onEnded({(value) in
//
//                        let x = value.location.x
//
//                        let screen = UIScreen.main.bounds.width - 30
//                        let percent = x  / screen
//
//                            // update current time after draf
//                        self.player.currentTime = Double(percent) * self.player.duration
//                    }))
//
//            }
//            .padding(.top)
//
//            HStack(spacing: UIScreen.main.bounds.width / 5 - 30){
//                Button(action: {
//                    if self.currentSong > 0 {
//                        self.currentSong -= 1
//                        self.changeSongs()
//                    }
//                }) {
//                    Image(systemName: "backward.fill").font(.title)
//                }
//
//                Button(action: {
//                    self.player.currentTime -= 15
//
////                    let decrease = self.player.currentTime - 15
////
////                    // if -15s would go beyond start of total time, go to start
////                    if decrease < 0 {
////                        self.player.currentTime = decrease
////                    }
//                }) {
//                    Image(systemName: "gobackward.15").font(.title)
//                }
//
//                Button(action: {
//                    if self.player.isPlaying {
//                        self.player.pause()
//                        self.isPlaying = false
//                    } else {
//                        if self.isFinished {
//                            self.player.currentTime = 0
//                            self.width = 0
//                            self.isFinished = false
//                        }
//
//                        self.player.play() // plays the music
//                        self.isPlaying = true
//                    }
//
//
//                }) {
//                    Image(systemName: self.isPlaying && !self.isFinished ? "pause.fill" : "play.fill").font(.title)
//                }
//
//                Button(action: {
//                    let increase = self.player.currentTime + 15
//
//                    // if +15s would go beyond end of total time, ignore
//                    if increase < self.player.duration {
//                        self.player.currentTime = increase
//                    }
//                }) {
//                    Image(systemName: "goforward.15").font(.title)
//                }
//
//                Button(action: {
//                    if self.songs.count - 1 != self.currentSong {
//                        self.currentSong += 1
//                        self.changeSongs()
//                    }
//                }) {
//                    Image(systemName: "forward.fill").font(.title)
//                }
//            }.padding(.top, 25)
//            .foregroundColor(.black)
//        }.padding()
//        .onAppear(){
////
//            // TODO try this...
//            //https://stackoverflow.com/questions/34563329/how-to-play-mp3-audio-from-url-in-ios-swift
//
////            "https://media2.ldscdn.org/assets/general-conference/april-2014-general-conference/2014-04-4050-elder-david-a-bednar-64k-eng.mp3"
////            let url = Bundle.main.path(forResource: "black", ofType: "mp3") // hardcode what song
//             // hardcode what song
//
//            // 2) With song from internet
////            let url = Bundle.main.path(forResource:
//
////             1) normal way that works with local file
//            let url = Bundle.main.path(forResource: self.songs[self.currentSong], ofType: "mp3")
//            self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
//
//
//            self.player.delegate = self.del
//
//            self.player.prepareToPlay() // not working... is it a CPU issue?
//            // TODO: restart and try again...
//            self.getData()
//
//            // this is like setTimout? Every second print the current time?
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
//                if self.player.isPlaying {
//                    let screen = UIScreen.main.bounds.width - 30
//
//                    let value = self.player.currentTime / self.player.duration
//
//                    // starts width at 0 (for red pill progress) (see state)
//                    // then every second increase based on value (% completion)
//                    self.width = screen * CGFloat(value)
////                    print(self.player.currentTime)
//                }
//            }
//
//            // listen for the "Finish" custom event
//            NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
//
//                self.isFinished = true
//            }
//        }
//    }
//
//    func getData() {
//
//        let asset = AVAsset(url: self.player.url!)
//        // I think this is where the metadata is being processed...
//        for i in asset.commonMetadata {
//            if i.commonKey?.rawValue == "artwork" {
//                let data = i.value as! Data
//                self.data = data
//            }
//
//            if i.commonKey?.rawValue == "title" {
//                let title = i.value as! String
//                self.title = title
//            }
//
//        }
//
//    }
//
//    func changeSongs() {
//        let url = Bundle.main.path(forResource: self.songs[self.currentSong], ofType: "mp3")
//        self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
//
//        self.player.delegate = self.del
//
//        self.data = .init(count:0)
//        self.title = ""
//        self.player.prepareToPlay()
//        self.getData()
//
//        self.isPlaying = true
//        self.isFinished = false
//
//        self.width = 0
//        self.player.play()
//
//    }
//}
//
//// overrides and callback functions?
//class AVdelegate : NSObject,AVAudioPlayerDelegate{
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//
//
//        // Fire the "Finish" event when the callback is called for "done"
//        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
//    }
//}
