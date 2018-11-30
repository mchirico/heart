import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class Utility {
  
  var ref: DatabaseReference!
  var db: Firestore!
  var fileURL: URL!
  
  
  func writeFile(fileName: String, writeString: String) {
    // Save data to file
    
    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    print("FilePath: \(fileURL.path)")
    self.fileURL = fileURL
    
    do {
      // Write to the file
      try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
      print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
    }
    
  }
  
  
  
  func readFile(fileName: String) -> (String,URL) {
    
    
    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    print("FilePath: \(fileURL.path)")
    
    
    var readString=""  // Used to store the file contents
    do {
      // Read the file contents
      readString = try String(contentsOf: fileURL)
    } catch let error as NSError {
      print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
    }
    print("File Text: \(readString)")
    return (readString,fileURL)
    
  }
  
  func dbwrite(key: String, value: String) {
    ref = Database.database().reference()
    db = Firestore.firestore()
    
    //valid_accounts
    self.ref.child("test_action").child("utility").setValue([key: value])
    Analytics.logEvent("Utility", parameters: ["dbwrite": value as NSObject])
  }
  
  func getURL() -> (URL?) {
    return self.fileURL
  }
  
  
  
  // Push to Firebase
  func pushToFirebase(localFile: URL, remoteFile: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    
    // Create a reference to the file you want to upload
    let uploadRef = storageRef.child(remoteFile)
    
    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = uploadRef.putFile(from: localFile, metadata: nil) { metadata, error in
      guard let metadata = metadata else {
        // Uh-oh, an error occurred!
        print("\n\n\n ****************************************\nError upload:\n\n\n")
        return
      }
      // Metadata contains file metadata such as size, content-type.
      let size = metadata.size
      // You can also access to download URL after upload.
      storageRef.downloadURL { (url, error) in
        guard let downloadURL = url else {
          // Uh-oh, an error occurred!
          return
        }
        print("\n\n\n ************ WORKED **************************\n\n")
        print("\n\n\n ************ WORKED **************************\n\n")
        print("\(downloadURL)\n\(size)")
        
        print("success")
      }
    }
    
    
    print("uploadTask \(uploadTask)")
  }
  
  
  
  
  
}
