//
//  DocumentPickerViewController.swift
//  CleverNotePicker
//
//  Created by Vikash Kumar on 12/05/17.
//  Copyright © 2017 Dave Krawczyk. All rights reserved.
//

import UIKit

class DocumentPickerViewController: UIDocumentPickerExtensionViewController {

    var notes = [Note]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var warningLbl : UILabel!
    @IBOutlet var confirmView: UIView!
    
    
    lazy var fileCoordinator: NSFileCoordinator = {
       let coord = NSFileCoordinator()
        coord.purposeIdentifier = self.providerIdentifier
        return coord
    }()
    
    override func prepareForPresentation(in mode: UIDocumentPickerMode) {
        
        if let sourceUrl = originalURL, sourceUrl.pathExtension != Note.fileExtension  {
            confirmBtn.isHidden = true
            warningLbl.isHidden = false
        }
        
        switch mode {
        case .exportToService :
            confirmBtn.setTitle("Export file to CleverNote", for: .normal)
            
        case .moveToService :
            confirmBtn.setTitle("Move file to CleverNote", for: .normal)
        case .import, .open :
            confirmView.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notes = Note.getAllNotesInFileSystem()
        tableView.reloadData()
    }
    
}

extension DocumentPickerViewController: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        let note = notes[indexPath.row]
        cell.lblTitle.text = note.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        dismissGrantingAccess(to: note.fileURL)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}

class TableCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
}
