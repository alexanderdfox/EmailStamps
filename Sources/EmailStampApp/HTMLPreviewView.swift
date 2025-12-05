import SwiftUI
import WebKit

#if os(iOS)
struct HTMLPreviewView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Disable zoom for email preview
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        
        // Set base URL to allow relative paths
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
        webView.loadHTMLString(html, baseURL: baseURL)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if HTML has changed
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
            uiView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String = ""
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            
            // Allow data URIs (for embedded images like base64)
            if url.scheme == "data" {
                decisionHandler(.allow)
                return
            }
            
            // Allow file:// URLs for local resources
            if url.scheme == "file" {
                decisionHandler(.allow)
                return
            }
            
            // Allow about:blank for initial load
            if url.absoluteString == "about:blank" {
                decisionHandler(.allow)
                return
            }
            
            // Block external navigation (http, https, etc.)
            decisionHandler(.cancel)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("HTMLPreviewView navigation error: \(error.localizedDescription)")
            #endif
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("HTMLPreviewView load error: \(error.localizedDescription)")
            #endif
        }
    }
}
#elseif os(macOS)
struct HTMLPreviewView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        
        // Disable zoom and selection for email preview
        webView.allowsMagnification = false
        webView.allowsBackForwardNavigationGestures = false
        
        // Set base URL to allow relative paths
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
        webView.loadHTMLString(html, baseURL: baseURL)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Only reload if HTML has changed
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
            nsView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String = ""
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            
            // Allow data URIs (for embedded images like base64)
            if url.scheme == "data" {
                decisionHandler(.allow)
                return
            }
            
            // Allow file:// URLs for local resources
            if url.scheme == "file" {
                decisionHandler(.allow)
                return
            }
            
            // Allow about:blank for initial load
            if url.absoluteString == "about:blank" {
                decisionHandler(.allow)
                return
            }
            
            // Block external navigation (http, https, etc.)
            decisionHandler(.cancel)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("HTMLPreviewView navigation error: \(error.localizedDescription)")
            #endif
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("HTMLPreviewView load error: \(error.localizedDescription)")
            #endif
        }
    }
}
#endif
