//
//  LogEntryViewController.swift
//  AdViewer
//
//  Created by Vincent Guerci on 03/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

class LogEntryViewController: UIViewController {
    @IBOutlet weak var logTextView: UITextView!
    var logEntry: LogEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = logEntry?.detail
    }
}
