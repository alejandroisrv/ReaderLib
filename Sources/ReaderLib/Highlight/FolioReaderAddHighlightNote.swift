//
//  FolioReaderAddHighlightNote.swift
//  FolioReaderKit
//
//  Created by David Pei on 10/16/19.
//

import UIKit

class FolioReaderAddHighlightNote: UIViewController {
    
    var textView: UITextView!
    var highlightLabel: UILabel!
    var scrollView: UIScrollView!
    var containerView = UIView()
    var highlight: Highlight!
    var highlightSaved = false
    var isEditHighlight = false
    var resizedTextView = false
    
    private var folioReader: FolioReader
    private var readerConfig: FolioReaderConfig
    
    init(withHighlight highlight: Highlight, folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.folioReader = folioReader
        self.highlight = highlight
        self.readerConfig = readerConfig
        
        super.init(nibName: nil, bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCloseButton(withConfiguration: readerConfig)
        prepareScrollView()
        configureTextView()
        configureLabel()
        configureNavBar()
        configureKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !highlightSaved && !isEditHighlight {
            guard let currentPage = folioReader.readerCenter?.currentPage else { return }
            currentPage.webView?.js("removeThisHighlight()")
        }
    }
    
    // MARK: - private methods
    
    private func prepareScrollView(){
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        scrollView.bounces = false
        
        containerView = UIView()
        containerView.backgroundColor = .white
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        let leftConstraint = NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let botConstraint = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, botConstraint])
    }
    
    private func configureTextView(){
        textView = UITextView()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        containerView.addSubview(textView)
        
        if isEditHighlight {
            textView.text = highlight.noteForHighlight
        }
        
        let leftConstraint = NSLayoutConstraint(item: textView!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
        let rightConstraint = NSLayoutConstraint(item: textView!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
        let topConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 100)
        let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height - 100)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
    }
    
    private func configureLabel() {
        highlightLabel = UILabel()
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        highlightLabel.numberOfLines = 3
        highlightLabel.font = UIFont.systemFont(ofSize: 15)
        highlightLabel.text = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        
        containerView.addSubview(self.highlightLabel!)
        
        let leftConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
        let rightConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
        let topConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 20)
        let heiConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 70)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
    }
    
    private func configureNavBar() {
        let navBackground = folioReader.isNight(readerConfig.nightModeMenuBackground, readerConfig.menuBackgroundColor)
        let tintColor = readerConfig.tintColor
        let navText = folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
        
        let titleAttrs = [NSAttributedString.Key.foregroundColor: readerConfig.tintColor]
        let saveButton = UIBarButtonItem(title: readerConfig.localizedSave, style: .plain, target: self, action: #selector(saveNote(_:)))
        saveButton.setTitleTextAttributes(titleAttrs, for: UIControl.State())
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        guard var userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @objc private func saveNote(_ sender: UIBarButtonItem) {
        if !textView.text.isEmpty {
            if isEditHighlight {
                DBAPIManager.shared.updateHighlight(id: highlight.id, note: textView.text)
            } else {
                highlight.noteForHighlight = textView.text
                DBAPIManager.shared.addHighlight(highlight: highlight)
            }
            highlightSaved = true
        }
        
        dismiss()
    }
}

// MARK: - UITextViewDelegate
extension FolioReaderAddHighlightNote: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        let newHeight = max(newFrame.height, newSize.height + 15)
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newHeight)
        textView.frame = newFrame;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}
