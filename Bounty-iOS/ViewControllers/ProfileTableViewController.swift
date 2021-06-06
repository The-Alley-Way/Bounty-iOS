//
//  ProfileTableViewController.swift
//  Bounty-iOS
//
//  Created by Runkai Zhang on 6/4/21.
//

import UIKit

import ImagePicker
import Kingfisher
import SkeletonView

import FirebaseStorage

import SPPermissions
import SPPermissionsCamera
import SPPermissionsPhotoLibrary
import SPPermissionsNotification

class ProfileTableViewController: UITableViewController, ImagePickerDelegate, ProfileFormVCDelegate {
    
    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pronounLabel: UILabel!
    @IBOutlet weak var bioLabel: UITextView!
    @IBOutlet weak var pfpButton: UIButton!
    
    let auth = AuthenticationService()
    
    var uploadProgress: Double?
    
    var pronoun: String = String()
    var bio: String = String()
    
    var shouldRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //print(shouldRefresh)
        if shouldRefresh {
            setup()
            self.shouldRefresh.toggle()
        }
    }
    
    func didFinishProfileFormVC(controller: ProfileFormViewController) {
        shouldRefresh = true
        controller.navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        let user = Profile(uid: auth.user!.uid)
        
        pfpImage.layer.masksToBounds = true
        pfpImage.layer.cornerRadius = pfpImage.frame.size.height / 2
        pfpImage.layer.borderWidth = 0;
        
        usernameLabel.showAnimatedGradientSkeleton()
        pronounLabel.showAnimatedGradientSkeleton()
        bioLabel.showAnimatedGradientSkeleton()
        pfpImage.showAnimatedGradientSkeleton()
        
        pfpButton.isHidden = true
        
        usernameLabel.text = auth.user?.displayName
        usernameLabel.hideSkeleton()
        
        user.getPronoun { pronoun, error in
            self.pronounLabel.text = pronoun.rawValue
            self.pronoun = pronoun.rawValue
            self.pronounLabel.hideSkeleton()
        }
        
        user.getBio { bio, error in
            self.bioLabel.text = bio
            self.bio = bio
            self.bioLabel.hideSkeleton()
        }
        
        var url = URL(string: "")
        
        if let pfpUrl = auth.user!.photoURL {
            url = pfpUrl
        } else {
            url = URL(string: "https://firebasestorage.googleapis.com/v0/b/bounty-eb852.appspot.com/o/profile_images%2Fdefault%2Fdefault_pfp_smol.png?alt=media&token=a4679f92-52e6-4a82-a794-81eaa3971471")
        }
        
        self.pfpImage.kf.setImage(with: url) { result in
            // `result` is either a `.success(RetrieveImageResult)` or a `.failure(KingfisherError)`
            switch result {
            case .success(_):
                // The image was set to image view:
                // print(value.image)
                
                // From where the image was retrieved:
                // - .none - Just downloaded.
                // - .memory - Got from memory cache.
                // - .disk - Got from disk cache.
                //print(value.cacheType)
                
                // The source object which contains information like `url`.
                // print(value.source)
                self.pfpImage.hideSkeleton()
                self.pfpButton.isHidden = false
            case .failure(let error):
                print(error) // The error happens
            }
        }
    }
    
    @IBAction func pfpClicked(_ sender: Any) {
        let authorized = SPPermissions.Permission.photoLibrary.authorized && SPPermissions.Permission.camera.authorized
        if !authorized {
            let permissions: [SPPermissions.Permission] = [.camera, .photoLibrary]
            let controller = SPPermissions.list(permissions)
            controller.present(on: self)
        } else {
            let configuration = Configuration()
            configuration.doneButtonTitle = "Finish"
            configuration.noImagesTitle = "Sorry! There are no images here!"
            configuration.recordLocation = false
            configuration.allowMultiplePhotoSelection = false
            configuration.allowVideoSelection = false
            
            let imagePickerController = ImagePickerController(configuration: configuration)
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            guard let uid = self.auth.user?.uid else {return}
            guard let imageData = images.first!.jpegData(compressionQuality: 1) else {return}
            let profileImgReference = Storage.storage().reference().child("profile_images").child(uid).child("\(uid).png")
            profileImgReference.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            self.pfpImage.showAnimatedGradientSkeleton()
            let uploadTask = profileImgReference.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                profileImgReference.downloadURL { url, error in
                    if let error = error {
                        print(error)
                    } else {
                        let request = self.auth.user!.createProfileChangeRequest()
                        request.photoURL = url
                        request.commitChanges { error in
                            if let error = error {
                                print(error)
                            }
                        }
                        
                        self.pfpImage.image = images[0]
                        self.pfpImage.hideSkeleton()
                    }
                }
            }
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                // print(snapshot.progress?.fractionCompleted ?? "")
                // Here you can get the progress of the upload process.
            })
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let destination = segue.destination as! ProfileFormViewController
        destination.delegate = self
        destination.currentProfile = Profile(uid: auth.user!.uid)
        destination.currentUser = auth.user!
        destination.currentPronoun = pronoun
        destination.currentBio = bio
    }
}
