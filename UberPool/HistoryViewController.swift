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
        
        parsePlistData()
    }
    
    
    func parsePlistData(){
        let plistData = ArchiveUtility.shared.readPlist()
        
        guard  let results = plistData else {
            historyTextView.text = "No History Available!"
            return
        }
        var stringToDisplay = ""
        for result in results{
            if let date = result["Date"], let startLocation = result["StartLocation"], let endLocation = result["EndLocation"]{
                stringToDisplay.append("\(date) \nStart Location: \(startLocation)\nEnd  Location: \(endLocation)\n\n")
            }
        }
        historyTextView.text = stringToDisplay
    }
}
