//
//  LogTableViewController.swift
//  AdViewer
//
//  Created by Vincent Guerci on 03/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

class LogTableViewController: UITableViewController {
    let logManager = LogManager.sharedInstance()
    let notificationCenter = NotificationCenter.default

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        notificationCenter.addObserver(self,
                selector: #selector(reload),
                name: NSNotification.Name(rawValue: kLogUpdateKey),
                object: nil)
    }

    @objc private func reload() {
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logManager.logs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogEntryCell", for: indexPath)

        let logEntry = logManager.logs[indexPath.row]
        cell.textLabel?.text = logEntry.title
        cell.detailTextLabel?.text = logEntry.subtitle
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogEntryDetail" {
            let logEntryVC = segue.destination as! LogEntryViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            logEntryVC.logEntry = logManager.logs[indexPath.row]
        }
    }
}
