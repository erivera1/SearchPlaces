//
//  ViewControllerExtension.swift
//  SearchPlaces
//
//  Created by Eliric on 10/29/20.
//


import UIKit
extension UIViewController {
    func presentAlert(message: String, onOk: @escaping ()->Void = { }) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) {
            _ in
            onOk()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
