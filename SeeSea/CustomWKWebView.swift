//
//  CustomWKWebView.swift
//  SeeSea
//
//  Created by 소정섭 on 9/21/24.
//

import SwiftUI
import WebKit

struct CustomWKWebView: UIViewRepresentable {

    var url: String

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let webView = WKWebView()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .secondaryLabel
        refreshControl.transform = CGAffineTransformMakeScale(0.7, 0.7)
        refreshControl.addTarget(webView, action: #selector(WKWebView.webViewPullToRefreshHandler(source: )), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        webView.scrollView.bounces = true
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: url) else { return }
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        DispatchQueue.main.async {
            applyTheme(to: webView)
        }
    }

    func applyTheme(to webView: WKWebView) {
        if webView.traitCollection.userInterfaceStyle == .dark {
            webView.evaluateJavaScript(CustomWKWebView.darkModeScript, completionHandler: nil)
        }
    }
    
    static var darkModeScript: String {
        return """
        document.body.style.backgroundColor = '#000';
        document.body.style.color = '#fff';
        """
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: CustomWKWebView
        
        init(parent: CustomWKWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.applyTheme(to: webView)
        }
    }
}

extension WKWebView: WKNavigationDelegate {
    @objc func webViewPullToRefreshHandler(source: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.reload()
            source.endRefreshing()
        }
    }
}

#Preview {
    CustomWKWebView(url: "http://cctv.trendworld.kr/cctv/woljeongri.php#google_vignette")
}
