//
//  WebviewViewModel.swift
//  Music Player Exp
//
//  Created by Jamis Charles on 1/10/21.
//

// copied from https://github.com/yamin335/SwiftUIWebView/blob/master/SwiftUIWebView/ViewModel.swift
// https://medium.com/@mdyamin/swiftui-mastering-webview-5790e686833e TODO: understand these pieces better...
// holds model data for the webview?

import Foundation
import Combine

// model that we can observe from various views...
class ViewModel: ObservableObject {
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showWebTitle = PassthroughSubject<String, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
}

// For identifiying WebView's forward and backward navigation
enum WebViewNavigation {
    case backward, forward, reload
}

// For identifying what type of url should load into WebView
enum WebUrlType {
    case localUrl, publicUrl
}
