import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn


class ViewController: UIViewController,GIDSignInUIDelegate  {
  var ref: DatabaseReference!
  var db: Firestore!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signIn()
    ref = Database.database().reference()
    db = Firestore.firestore()
    
    //valid_accounts
    self.ref.child("valid_accounts").child("heartRate").setValue(["username": "mchirico@gmail.com"])
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func buttonUpload(_ sender: UIButton) {
    let utility = Utility()
    utility.writeFile(fileName: "HeartRates.csv", writeString: "12\n,13\n")
    
    if let url = utility.getURL() {
      
      utility.pushToFirebase(localFile: url,
                             remoteFile: "HeartRate.csv")
    }
    
    
    
  }
  
}
