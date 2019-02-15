//
//  HistoryViewController.swift
//  UberPool
//
//  Created by abhishek.b.shukla on 15/02/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    let historyTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Abhisehk"
        
        return textView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        view.addSubview(historyTextView)
        
        NSLayoutConstraint.activate([
            historyTextView.topAnchor.constraint(equalTo: view.topAnchor),
            historyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
}
