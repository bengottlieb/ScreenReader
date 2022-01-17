//
//  ViewController.swift
//  ScreenReader
//
//  Created by Ben Gottlieb on 1/16/22.
//

import UIKit
import WebKit


class ViewController: UIViewController {
	var webview: WKWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		webview = WKWebView(frame: view.bounds)
		
		view.addSubview(webview)
		webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		webview.load(URLRequest(url: URL(string: "https://apple.com")!))
		// Do any additional setup after loading the view.
		
		let button = UIButton(type: .roundedRect)
		button.setTitle("Check", for: .normal)
		button.addTarget(self, action: #selector(check), for: .touchUpInside)
		view.addSubview(button)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
		button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
	
	@objc func check() {
		let reader = ScreenReader(view: view)!
		Task {
			if await reader.check(for: "watch") { print("Found watch") }
		}
	}


}

