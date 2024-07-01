//
//  File.swift
//  
//
//  Created by Nikita Stepanov on 01.07.2024.
//

import Foundation
import UIKit
import WebKit

public class AdvertiserViewController: UIViewController {
    
    private var adWebView: WKWebView!
    private var adUrl: URL
    
    private var isFrameScren: Bool = {
        let isFrame = UIScreen.main.bounds.height / UIScreen.main.bounds.width < 2
        return isFrame
    }()
    
    public let netAlert = UIAlertController(title: "The connection problems!",
                                            message: "To play you should be connected",
                                            preferredStyle: .alert)
    
    private var topConstraint: NSLayoutConstraint?
    
    public init(url: URL) {
        self.adUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func configWebView() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        return configuration
    }
    
    private func setUp() {
        view.backgroundColor = .black
        
        adWebView = WKWebView(frame: view.bounds, configuration: configWebView())
        adWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adWebView)
        
        NSLayoutConstraint.activate([
            adWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            adWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        topConstraint = adWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: isFrameScren ? 0 : 70)
        topConstraint!.isActive = true
        
        let request = URLRequest(url: adUrl)
        adWebView.load(request)
    }
    
    func showNetPopUp() {
        present(netAlert, animated: true, completion: nil)
    }
    
    func hideNetPopUp() {
        netAlert.dismiss(animated: true)
    }
    
    func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.hideNetPopUp()
                }
            } else {
                DispatchQueue.main.async {
                    self.showNetPopUp()
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    override public func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        topConstraint?.constant = self.view.frame.size.height > self.view.frame.size.width ? (isFrameScren ? 0 : 70) : 0
        view.updateConstraintsIfNeeded()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkInternetConnection()
    }
}
