//
//  ViewController.swift
//  DeviceManager
//
//  Created by Chandimal, Sameera on 3/13/18.
//  Copyright © 2018 Pearson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var video = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let session = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("Error")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        
        view.layer.addSublayer(video)
        session.startRunning()
    }
    
    @IBAction func onClickDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    if let name = object.stringValue {
                        
                        FirebaseHandler.findDeviceExist(name: name, completion: { (isExist, type, model) in
                            if isExist {
                                FirebaseHandler.getOwner(type: type, model: model, name: name, completion: { (borrower) in
                                    if borrower == "Locker" {
                                        self.handOverDeviceToPerson(type: type, model: model, name: name)
                                    } else {
                                        let alert = UIAlertController(title: "\(name)\n(\(borrower))", message: nil, preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Return back to Locker", style: .default, handler: { (nil) in
                                            FirebaseHandler.updateBorrower(type: type, model: model, name: name, borrower: "Locker")
                                            self.dismiss(animated: true, completion: nil)
                                        }))
                                        alert.addAction(UIAlertAction(title: "Hand Over to another", style: .default, handler: { (nil) in
                                            self.handOverDeviceToPerson(type: type, model: model, name: name)
                                        }))
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            } else {
                                self.showMessage("Error", "This device is not exist!")
                            }
                        })
                    }
                }
            }
        }
    }
}

extension ViewController {
    
    func handOverDeviceToPerson(type: String, model: String, name: String) {
        let alert = UIAlertController(title: name, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Hand Over", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let borrowerName = textField.text {
                FirebaseHandler.updateBorrower(type: type, model: model, name: name, borrower: borrowerName)
                self.dismiss(animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { (textField) in
            textField.placeholder = "Borrower's name"
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated:true, completion: nil)
    }
}

extension UIViewController {

    func showMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
