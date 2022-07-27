//
//  ViewController.swift
//  WebSocketKit
//
//  Created by Ryosuke Ito on 9/16/17.
//  Copyright © 2017 manicmaniac. All rights reserved.
//

import UIKit
import WebSocketKit

class ViewController: UIViewController, UITextFieldDelegate, WSKWebSocketDelegate {

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIBarButtonItem!
    @IBOutlet private weak var toolbarBottomLayoutConstraint: NSLayoutConstraint!
    private var webSocket: WSKWebSocket!
    private var originalToolbarBottomLayoutConstraintConstant: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        originalToolbarBottomLayoutConstraintConstant = toolbarBottomLayoutConstraint.constant
        let url = URL(string: "ws://echo.websocket.org/")!
        let webSocket = WSKWebSocket(url: url)
        webSocket.delegate = self
        self.webSocket = webSocket
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: view.window)
        textField.becomeFirstResponder()
        webSocket.open()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webSocket.close()
    }

    @IBAction private func sendButtonDidTap(_ sender: UIBarButtonItem) {
        sendText()
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let animationCurveRawValue = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue)!
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        toolbarBottomLayoutConstraint.constant = keyboardFrame.height
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve.keyboardOptions, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationCurveRawValue = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue)!
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        toolbarBottomLayoutConstraint.constant = originalToolbarBottomLayoutConstraintConstant
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve.keyboardOptions, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func sendText() {
        if let text = textField.text {
            webSocket.send(text)
            let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            attributedText.append(NSAttributedString(string: text + "\n"))
            textView.attributedText = attributedText
            textField.text = ""
            scrollTextViewToBottom()
        }
    }

    private func scrollTextViewToBottom() {
        if textView.text.count > 0 {
            let bottomRange = NSRange(location: textView.text.count - 1, length: 1)
            textView.scrollRangeToVisible(bottomRange)
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText()
        return false
    }

    // MARK: - WSKWebSocketDelegate

    func webSocketDidOpen(_ webSocket: WSKWebSocket) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.append(NSAttributedString(string: "Connection opened\n", attributes: [.foregroundColor: UIColor.lightGray]))
        textView.attributedText = attributedText
    }

    func webSocket(_ webSocket: WSKWebSocket, didReceiveMessage message: String) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.append(NSAttributedString(string: message + "\n", attributes: [.foregroundColor: UIColor.blue]))
        textView.attributedText = attributedText
        scrollTextViewToBottom()
    }

    func webSocketDidClose(_ webSocket: WSKWebSocket) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.append(NSAttributedString(string: "Connection closed\n", attributes: [.foregroundColor: UIColor.lightGray]))
        textView.attributedText = attributedText
    }

    func webSocket(_ webSocket: WSKWebSocket, didFailWithError error: Error) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.append(NSAttributedString(string: "Connection error\n", attributes: [.foregroundColor: UIColor.red]))
        textView.attributedText = attributedText
    }

}

private extension UIView.AnimationCurve {

    var keyboardOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(rawValue << 16))
    }
    
}
