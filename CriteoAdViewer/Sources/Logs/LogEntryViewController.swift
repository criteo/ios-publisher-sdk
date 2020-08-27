//
//  LogEntryViewController.swift
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

class LogEntryViewController: UIViewController {
    @IBOutlet weak var logTextView: UITextView!
    var logEntry: LogEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.text = logEntry?.detail
    }
}
