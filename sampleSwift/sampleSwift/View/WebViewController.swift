//
//  WebViewController.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 16/04/2024.
//

import UIKit
import WebKit
import OSLog

class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var url: URL!
    private var logger = Logger()

    init(_ url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        clearLocalStorageBeforeInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clearLocalStorageBeforeInit()
    }
    
    func clearLocalStorageBeforeInit() {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                Logger().log("WKWebsiteDataStore record deleted: \(record)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: .zero)
        view = webView

        if #available(iOS 16.4, *) { webView.isInspectable = true }

        let myRequest = URLRequest(url: url)
        logger.debug("Opening webview with url: \(myRequest)")
        webView.load(myRequest)
    }
}
