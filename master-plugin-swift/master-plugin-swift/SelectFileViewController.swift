//
//  SelectFileViewController.swift
//  Copyright © 2017 Sequencing.com. All rights reserved.
//

import UIKit
import QuartzCore


protocol UserSignOutProtocol {
    
    func userDidSignOut() -> Void
}



class SelectFileViewController: UIViewController, SQFileSelectorProtocol {
    
    public var delegate: UserSignOutProtocol?
    
    let kMainQueue = DispatchQueue.main
    let kBackgroundQueue = DispatchQueue.global()
    
    let oauthApiHelper = SQOAuth.sharedInstance()
    let filesApiHelper = SQFilesAPI.sharedInstance()
    let appChainsHelper = AppChainsHelper()
    
    // actiity indicator
    var messageFrame = UIView()
    var strLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    
    var selectedFile = NSDictionary()
    
    // UI items
    @IBOutlet weak var buttonSelectFile: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var getFileInfo: UISegmentedControl!
    @IBOutlet weak var segmentedControlView: UIView!
    
    
    @IBOutlet weak var batchButtonView: UIView!
    @IBOutlet weak var batchButton: UIButton!
    
    @IBOutlet weak var selectedFileTagline: UILabel!
    @IBOutlet weak var selectedFileName: UILabel!
    
    @IBOutlet weak var vitaminDInfo: UILabel!
    @IBOutlet weak var melanomaInfo: UILabel!
    
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Using genetic file"
        
        // adjust buttons view
        buttonView.layer.cornerRadius = 5
        buttonView.layer.masksToBounds = true
        buttonView.layer.borderColor = UIColor.init(colorLiteralRed: 35/255.0, green: 121/255.0, blue: 254/255.0, alpha: 1.0).cgColor
        buttonView.layer.borderWidth = 1.0
        
        segmentedControlView.layer.cornerRadius = 5
        segmentedControlView.layer.masksToBounds = true
        
        batchButtonView.layer.cornerRadius = 5
        batchButtonView.layer.masksToBounds = true
        batchButtonView.layer.borderColor = UIColor.init(colorLiteralRed: 35/255.0, green: 121/255.0, blue: 254/255.0, alpha: 1.0).cgColor
        batchButtonView.layer.borderWidth = 1.0
            
        selectedFileTagline.isHidden = true
        selectedFileName.isHidden = true
        getFileInfo.isHidden = true
        segmentedControlView.isHidden = true
        batchButtonView.isHidden = true
        batchButton.isHidden = true
        vitaminDInfo.isHidden = true
        melanomaInfo.isHidden = true
    }
    
    
    deinit {
        filesApiHelper?.delegate = nil
    }
    
    
    
    // MARK: - Actions
    @IBAction func loadFilesButtonPressed(_ sender: AnyObject) {
        self.view.isUserInteractionEnabled = false
        self.startActivityIndicatorWithTitle("Loading Files")
        
        selectedFileTagline.isHidden = true
        selectedFileName.isHidden = true
        getFileInfo.isHidden = true
        segmentedControlView.isHidden = true
        batchButtonView.isHidden = true
        batchButton.isHidden = true
        vitaminDInfo.isHidden = true
        melanomaInfo.isHidden = true
        
        filesApiHelper!.showFiles(withTokenProvider: oauthApiHelper!,
                                  showCloseButton: true,
                                  previouslySelectedFileID: nil,
                                  delegate: self)
        
        
        
        
    }
    
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        if delegate != nil {
            delegate!.userDidSignOut()
        }
    }
    
    
    
    // MARK: - SQFileSelectorProtocolDelegate
    func selectedGeneticFile(_ file: [AnyHashable : Any]!) {
        if file != nil {
            
            let fileDict = file as NSDictionary!
            
            self.dismiss(animated: true, completion: nil)
            print(file)
            
            if fileDict!.allKeys.count > 0 {
                kMainQueue.async {
                    self.stopActivityIndicator()
                    self.view.isUserInteractionEnabled = true
                    self.selectedFile = fileDict!
                    let fileCategory = fileDict!.object(forKey: "FileCategory") as! String
                    var fileName: NSString
                    
                    if fileCategory.range(of: "Community") != nil {
                        fileName = NSString(format: "%@ - %@", fileDict!.object(forKey: "FriendlyDesc1") as! NSString, fileDict!.object(forKey: "FriendlyDesc2") as! NSString)
                    } else {
                        fileName = NSString(format: "%@", fileDict!.object(forKey: "Name") as! NSString)
                    }
                    
                    self.selectedFileName.text = fileName as String
                    
                    self.selectedFileTagline.isHidden = false
                    self.selectedFileName.isHidden = false
                    self.getFileInfo.isHidden = false
                    self.segmentedControlView.isHidden = false
                    self.batchButtonView.isHidden = false
                    self.batchButton.isHidden = false
                }
            } else {
                kMainQueue.async {
                    self.stopActivityIndicator()
                    self.view.isUserInteractionEnabled = true
                    self.showAlertWithMessage("Sorry, can't load genetic files")
                    
                    self.selectedFileTagline.isHidden = true
                    self.selectedFileName.isHidden = true
                    self.getFileInfo.isHidden = true
                    self.segmentedControlView.isHidden = true
                    self.batchButtonView.isHidden = true
                    self.batchButton.isHidden = true
                }
            }
        } else {
            kMainQueue.async {
                self.stopActivityIndicator()
                self.view.isUserInteractionEnabled = true
                self.showAlertWithMessage("Sorry, can't load genetic files")
                
                self.selectedFileTagline.isHidden = true
                self.selectedFileName.isHidden = true
                self.getFileInfo.isHidden = true
                self.segmentedControlView.isHidden = true
                self.batchButtonView.isHidden = true
                self.batchButton.isHidden = true
            }
        }
    }
    
    
    func errorWhileReceivingGeneticFiles(_ error: Error!) {
        kMainQueue.async {
            print("errorWhileReceivingGeneticFiles")
            self.stopActivityIndicator()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    
    func closeButtonPressed() -> Void {
        kMainQueue.async {
            print("closeButtonPressed")
            self.stopActivityIndicator()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    
    
    // MARK: - Get genetic information
    @IBAction func getGeneticInfoPressed(_ sender: UISegmentedControl) {
        if self.selectedFile.allKeys.count > 0 {
            if let selectedSegmentItem = sender.titleForSegment(at: sender.selectedSegmentIndex) {
                
                if selectedSegmentItem.range(of: "vitamin") != nil {
                    self.getVitaminDInfo()
                    
                } else {
                    self.getMelanomaInfo()
                }
            }
        } else {
            self.showAlertWithMessage("Please select genetic file above")
        }
    }
    
    
    
    func getVitaminDInfo() -> Void {
        if selectedFile.allKeys.count > 0 {
            if let fileID = selectedFile.object(forKey: "Id") as! NSString? {
                
                self.vitaminDInfo.isHidden = true
                self.view.isUserInteractionEnabled = false
                self.startActivityIndicatorWithTitle("Loading info...")
                
                self.kBackgroundQueue.async {
                    self.appChainsHelper.requestForChain88BasedOnFileID(fileID: fileID as String,
                                                                        tokenProvider: SQOAuth.sharedInstance(),
                                                                        completion: { (vitaminDValue) in
                        
                        self.handleVitaminDLabel(vitaminDValue)
                    })
                }
            } else {
                self.view.isUserInteractionEnabled = true
                self.vitaminDInfo.isHidden = true
                self.showAlertWithMessage("Corrupted selected file, can't load vitamin D information.")
            }
        } else {
            self.view.isUserInteractionEnabled = true
            self.vitaminDInfo.isHidden = true
            self.showAlertWithMessage("Corrupted user info, can't load vitamin D information.")
        }
    }
    
    
    func getMelanomaInfo() -> Void {
        if selectedFile.allKeys.count > 0 {
            if let fileID = selectedFile.object(forKey: "Id") as! NSString? {
                
                self.melanomaInfo.isHidden = true
                self.view.isUserInteractionEnabled = false
                self.startActivityIndicatorWithTitle("Loading info...")
                
                self.kBackgroundQueue.async {
                    self.appChainsHelper.requestForChain9BasedOnFileID(fileID: fileID as String,
                                                                       tokenProvider: SQOAuth.sharedInstance(),
                                                                       completion: { (melanomaRiskValue) in
                        
                        self.handleMelanomaLabel(melanomaRiskValue)
                    })
                }
            } else {
                self.stopActivityIndicator()
                self.view.isUserInteractionEnabled = true
                self.melanomaInfo.isHidden = true
                self.showAlertWithMessage("Corrupted selected file, can't load melanoma information.")
            }
        } else {
            self.stopActivityIndicator()
            self.view.isUserInteractionEnabled = true
            self.melanomaInfo.isHidden = true
            self.showAlertWithMessage("Corrupted user info, can't load melanoma information.")
        }
    }
    
    
    
    @IBAction func getVitaminDMelanomaInBatchRequest(_ sender: Any) {
        if selectedFile.allKeys.count > 0 {
            if let fileID = selectedFile.object(forKey: "Id") as! NSString? {
                
                self.vitaminDInfo.isHidden = true
                self.melanomaInfo.isHidden = true
                self.view.isUserInteractionEnabled = false
                self.startActivityIndicatorWithTitle("Loading info...")
                
                kBackgroundQueue.async {
                    self.appChainsHelper.batchRequestForChain88AndChain9BasedOnFileID(fileID: fileID as String,
                                                                                      tokenProvider: SQOAuth.sharedInstance(),
                                                                                      completion: { (appChainsResults) in
                        
                        if appChainsResults != nil {
                            
                            // @appchainsResults - result of string values for chains for batch request, it's an array of dictionaries
                            // each dictionary has following keys: "appChainID": appChainID string, "appChainValue": *String value
                            for appChainResult in appChainsResults! {
                                let appChainResultDict = appChainResult as! NSDictionary
                                let appChainName = appChainResultDict.object(forKey: "appChainID")
                                let appChainValue = appChainResultDict.object(forKey: "appChainValue")
                                
                                if appChainName != nil && appChainValue != nil {
                                    
                                    let appChainNameString = appChainName! as! String
                                    
                                    if appChainNameString.range(of: "Chain88") != nil {
                                        self.handleVitaminDLabel(appChainValue as! NSString!)
                                        
                                    } else if appChainNameString.range(of: "Chain9") != nil {
                                        self.handleMelanomaLabel(appChainValue as! NSString!)
                                    }
                                    
                                } else {
                                    self.kMainQueue.async {
                                        self.stopActivityIndicator()
                                        self.view.isUserInteractionEnabled = true
                                        self.vitaminDInfo.isHidden = true
                                        self.melanomaInfo.isHidden = true
                                        self.showAlertWithMessage("Sorry, error from server, can't load genetic information.")
                                    }
                                }
                            }
                        } else {
                            self.kMainQueue.async {
                                self.stopActivityIndicator()
                                self.view.isUserInteractionEnabled = true
                                self.vitaminDInfo.isHidden = true
                                self.melanomaInfo.isHidden = true
                                self.showAlertWithMessage("Sorry, error from server, can't load genetic information.")
                            }
                        }
                    })
                }
            } else {
                self.vitaminDInfo.isHidden = true
                self.melanomaInfo.isHidden = true
                self.showAlertWithMessage("Corrupted user info, can't load genetic information.")
            }
        } else {
            self.vitaminDInfo.isHidden = true
            self.melanomaInfo.isHidden = true
            self.showAlertWithMessage("Corrupted user info, can't load genetic information.")
        }
    }
    
    
        
    
    
    
    
    
    func handleVitaminDLabel(_ vitaminDValue: NSString?) -> Void {
        kMainQueue.async {
            self.stopActivityIndicator()
            self.view.isUserInteractionEnabled = true
            self.vitaminDInfo.isHidden = false
            
            if vitaminDValue != nil {
                if vitaminDValue!.length > 0 {
                    
                    if (vitaminDValue! as String).lowercased().range(of: "false") != nil {
                        self.vitaminDInfo.text = "There is no issue with vitamin D"
                        
                    } else if (vitaminDValue! as String).lowercased().range(of: "true") != nil {
                        self.vitaminDInfo.text = "There is an issue with vitamin D"
                        
                    } else {
                        self.vitaminDInfo.text = "Sorry, there is invalid vitamin D information"
                    }
                    
                } else {
                    self.vitaminDInfo.text = "Sorry, there is error from the server."
                }
            } else {
                self.vitaminDInfo.text = "Sorry, there is error from the server."
            }
        }
    }
    
    
    
    func handleMelanomaLabel(_ melanomaRiskValue: NSString?) -> Void {
        kMainQueue.async {
            self.stopActivityIndicator()
            self.view.isUserInteractionEnabled = true
            self.melanomaInfo.isHidden = false
            
            if melanomaRiskValue != nil {
                if melanomaRiskValue!.length > 0 {
                    
                    self.melanomaInfo.text = NSString(format: "Melanoma issue level is: %@", melanomaRiskValue!.capitalized) as String
                    
                } else {
                    self.melanomaInfo.text = "Sorry, there is error from the server."
                }
            } else {
                self.melanomaInfo.text = "Sorry, there is error from the server."
            }
        }
    }
    
    
    
    // MARK: - Activity indicator
    func startActivityIndicatorWithTitle(_ title: String) -> Void {
        kMainQueue.async { () -> Void in
            
            self.strLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 90, height: 30))
            self.strLabel.text = title
            self.strLabel.font = UIFont.systemFont(ofSize: 13)
            self.strLabel.textColor = UIColor.gray
            
            let xPos: CGFloat = self.view.frame.midX - 60
            // let yPos: CGFloat = self.mainVC.view.frame.midY + 50
            self.messageFrame = UIView(frame: CGRect(x: xPos, y: 60, width: 120, height: 30))
            self.messageFrame.layer.cornerRadius = 15
            self.messageFrame.backgroundColor = UIColor.clear
            
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            self.activityIndicator.startAnimating()
            
            self.messageFrame.addSubview(self.activityIndicator)
            self.messageFrame.addSubview(self.strLabel)
            self.view.addSubview(self.messageFrame)
        }
    }
    
    
    func stopActivityIndicator() -> Void {
        kMainQueue.async { () -> Void in
            self.activityIndicator.stopAnimating()
            self.messageFrame.removeFromSuperview()
        }
    }
    
    
    // MARK: - Alert message
    func showAlertWithMessage(_ message: NSString) -> Void {
        let alert = UIAlertController(title: nil, message: message as String, preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
}
