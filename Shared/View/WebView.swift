//
//  WebView.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  let url: URL

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.load(.init(url: url))
    return webView
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
  }
}

struct WebView_Previews: PreviewProvider {
  static var previews: some View {
    WebView(url: .init(string: "https://google.co.jp")!)
  }
}
