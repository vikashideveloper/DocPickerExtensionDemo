/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import UIKit

class NotesTableViewController: UITableViewController {

  // MARK: - Properties
  var notes = [Note]()
  let noteSegueIdentifier = "noteSegue"
  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  // MARK: - View Life Cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshNoteList()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == noteSegueIdentifier else {
      return
    }
    
    let noteViewController = segue.destination as! NoteViewController
    let noteDocument = sender as! Note
    noteViewController.note = noteDocument
  }
}

// MARK: - Internal
extension NotesTableViewController {

  func refreshNoteList() {
    notes = Note.getAllNotesInFileSystem()
    tableView.reloadData()
  }
}

// MARK: - IBActions
extension NotesTableViewController {

  @IBAction func addButtonTapped(_ sender: AnyObject) {

    let alertController = UIAlertController(title: "Add Note", message: "Please enter a title for your new note", preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Note Title"
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    
    let okayAction = UIAlertAction(title: "Okay", style: .default) { action in
      guard let noteTitle = alertController.textFields?.first?.text else {
        return
      }
        
      guard let note = Note.createNote(noteTitle) else {
        return
      }

      note.save(to: note.fileURL, for: .forCreating) { [unowned self] (success) -> Void in
        guard success else {
          print("Save unsuccessful")
          return
        }
        
        self.performSegue(withIdentifier: self.noteSegueIdentifier, sender: note)
        self.notes.append(note)
      }
    }

    alertController.addAction(okayAction)
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension NotesTableViewController {
  
  // MARK: - CellIdentifiers
  fileprivate enum CellIdentifier: String {
    case NoteCell = "noteCell"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.NoteCell.rawValue, for: indexPath)
    let noteDocument = notes[(indexPath as NSIndexPath).row]
    cell.textLabel?.text = noteDocument.title
    return cell
  }
}

// MARK: - UITableViewDelegate
extension NotesTableViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let noteDocument = notes[(indexPath as NSIndexPath).row]
    performSegue(withIdentifier: noteSegueIdentifier, sender: noteDocument)
  }
}
