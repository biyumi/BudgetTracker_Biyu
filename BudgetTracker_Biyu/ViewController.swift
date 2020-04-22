//
//  ViewController.swift
//  BudgetTracker_Biyu
//
//  Created by Biyu Mi on 1/15/20.
//  Copyright © 2020 Biyu Mi. All rights reserved.
//

import UIKit

protocol segueToBucketViewDelegate {
    func tableCellSelected(name: String)
}
protocol bucketDelegate {
    func fetchAllData() -> BucketData
    func addBucket(name: String, limit: Double, defaultBucketName:String, hue:CGFloat, brightness: CGFloat) -> Bool
    func addTransaction(amount: Double, bucket: String, description: String) -> Bool
    func addBudget(amount: Double, defaultBucketName:String, renewDate:String, renewFrequency:Int) -> Bool
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, segueToBucketViewDelegate {
    let defaultBucketName = "other"
    let defaultColor = "Red"
    let topViewPortion: CGFloat = 0.3
    let innerViewYPortion: CGFloat = 0.2
    let innerViewXPortion: CGFloat = 0.1
    let backgroundColor = UIColor.init(hue: 1, saturation: 0, brightness: 0.17, alpha: 1)
    let backgroundColorWithAlpha = UIColor.init(hue: 1, saturation: 0, brightness: 0.39, alpha: 0.8)
    let okayColor = UIColor.init(hue: 0.43, saturation: 1, brightness: 0.7, alpha: 1)
    let badColor = UIColor.init(hue: 0, saturation: 1, brightness: 0.6, alpha: 1)
    
    let bucketModel = BucketModel()
    
    let cellReuseIdentifier = "cell"
    
    let colorDictionary = [
        "Red": ["hue": CGFloat(0),
                "brightness": CGFloat(1)],
        "Yellow": ["hue": CGFloat(0.14),
                   "brightness": CGFloat(1)],
        "Green": ["hue": CGFloat(0.27),
                  "brightness": CGFloat(1)],
        "Blue": ["hue": CGFloat(0.7),
                 "brightness": CGFloat(1)],
        "Orange": ["hue": CGFloat(0.08),
                   "brightness": CGFloat(1)],
        "Purple": ["hue": CGFloat(0.75),
                   "brightness": CGFloat(1)],
        "Cyan": ["hue": CGFloat(0.5),
                 "brightness": CGFloat(1)]]
        
    var delegate: bucketDelegate?
    
    var allBuckets: [Bucket] = []
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bucketPickerView: UIPickerView!
    @IBOutlet var colorPickerView: UIPickerView!
    @IBOutlet var bucketTextField: UITextField!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var budgetAmountField: UITextField!
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var inputDialogueView: UIView!
    @IBOutlet var addBudgetDialogueView: UIView!
    @IBOutlet var addBucketDialogueView: UIView!
    @IBOutlet var topDisplayField: UILabel!
    @IBOutlet var bucketNameField: UITextField!
    @IBOutlet var bucketLimitField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var renewDateTextField: UITextField!
    @IBOutlet var renewFrequency: UITextField!
    
    @IBAction func addClicked(_sender: UIButton!){
        self.inputDialogueView.isHidden = false
    }
    
    @IBAction func closeDialogue(_sender: Any){
        self.inputDialogueView.isHidden = true
        self.addBudgetDialogueView.isHidden = true
        self.addBucketDialogueView.isHidden = true
    }
    
    @IBAction func addBucketClicked(_sender: Any){
        self.addBucketDialogueView.isHidden = false
    }
    
    @IBAction func budgetClicked(_sender: Any){
        self.addBudgetDialogueView.isHidden = false
    }
    
    @IBAction func addBucket(_sender: Any){
        let bucketName = bucketNameField.text!
        let bucketLimit = Double(bucketLimitField.text!)!
        let bucketColor = colorDictionary[colorTextField.text!]!
        let success = self.delegate?.addBucket(name: bucketName, limit: bucketLimit, defaultBucketName: defaultBucketName, hue: bucketColor["hue"]!, brightness: bucketColor["brightness"]!)
        if(success!){
            resetData()
        }
        self.resetInput()
        self.addBucketDialogueView.isHidden = true
    }
    
    @IBAction func addBudget(_sender: Any){
        let budgetAmount = Double(budgetAmountField.text!)!
        let renewFrequency = Int(self.renewFrequency.text!)!
        let success = self.delegate?.addBudget(amount: budgetAmount, defaultBucketName: defaultBucketName, renewDate: renewDateTextField.text!, renewFrequency: renewFrequency)
        if(success!){
            resetData()
        }
        self.resetInput()
        self.addBudgetDialogueView.isHidden = true
    }
    
    @IBAction func addTransaction(_sender: Any){
        let transAmount = Double(amountField.text!)!
        let description =  descriptionField.text!
        let bucket = bucketTextField.text!
        let success = self.delegate?.addTransaction(amount: transAmount, bucket: bucket, description: description)
        if(success!){
            resetData()
        }
        self.resetInput()
        self.inputDialogueView.isHidden = true
    }
    
    func resetInput(){
        self.amountField.text = ""
        self.bucketTextField.text = defaultBucketName
        self.descriptionField.text = ""
        self.bucketNameField.text = ""
        self.bucketLimitField.text = ""
    }
    
    func resetData(){
        let data = self.delegate!.fetchAllData()
        allBuckets = data.buckets
        self.tableView.reloadData()
        self.setTopDisplay(totalBudget: data.totalBudget, totalSpending: data.totalSpending)
    }
    
    override func loadView() {
        super.loadView()
        print("view load")
        self.delegate = bucketModel
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let data = self.delegate!.fetchAllData()
        let totalBudget = data.totalBudget
        let totalSpending = data.totalSpending
        allBuckets = data.buckets
        
        self.setupTopView(screenWidth: screenWidth, screenHeight: screenHeight, totalBudget: totalBudget, totalSpending: totalSpending)
        self.setupTableView(screenWidth: screenWidth, screenHeight: screenHeight, buckets: allBuckets)
        inputDialogueView = self.setupTransactionDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        addBudgetDialogueView = self.setupBudgetDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        addBucketDialogueView = self.setupBucketDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        self.view.addSubview(addBudgetDialogueView)
        self.view.addSubview(addBucketDialogueView)
        self.view.addSubview(inputDialogueView)
        
        if(data.buckets.count > 0){
            self.budgetAmountField.text = String(data.totalBudget)
            self.renewDateTextField.text = data.renewDate
            self.renewFrequency.text = String(data.renewFrequency)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        // Do any additional setup after loading the view.
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.inputDialogueView.addGestureRecognizer(tap1)
        self.addBudgetDialogueView.addGestureRecognizer(tap2)
        self.addBucketDialogueView.addGestureRecognizer(tap3)
        
        if (self.allBuckets.count == 0){
            self.addBudgetDialogueView.isHidden = false
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        print("tap")
    }
    
    func setupBucketDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{
        colorPickerView = UIPickerView(frame: CGRect(x: 0, y: screenHeight * 0.7, width: screenWidth, height: screenHeight * 0.3))
        //bucketPickerView.isHidden = true
        colorPickerView.delegate = self
        colorPickerView.dataSource = self
        colorPickerView.backgroundColor = backgroundColorWithAlpha
        
        let dialogueView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dialogueView.backgroundColor = backgroundColorWithAlpha
        
        let innerWidth = (1 - innerViewXPortion * 2) * screenWidth
        let innerHeight = (1 - innerViewYPortion * 2) * screenHeight
        let innerViewX = innerViewXPortion * screenWidth
        let innerViewY = innerViewYPortion * screenHeight
        
        let innerDialogueView = UIView(frame: CGRect(x: innerViewX, y: innerViewY, width: innerWidth, height: innerHeight))
        innerDialogueView.backgroundColor = backgroundColor
        
        let bottomButtonY = innerHeight * 0.8
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        let confirmButton = UIButton(frame: CGRect(x: 0.5 * innerWidth, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
        confirmButton.setTitle("Confirm", for: UIControl.State.normal)
        
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        confirmButton.titleLabel?.textAlignment = .center
        confirmButton.titleLabel?.textColor = UIColor.white
        confirmButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        
        cancelButton.addTarget(self, action: #selector(ViewController.closeDialogue(_sender:)), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(ViewController.addBucket(_sender:)), for: .touchUpInside)
        
        innerDialogueView.addSubview(cancelButton)
        innerDialogueView.addSubview(confirmButton)
        
        let padding: CGFloat = 0.05
        let contentWidth = innerWidth * (1 - 2 * padding)
        let contentHeight = innerHeight * 0.1
        let contentX = innerWidth  * padding
        
        let nameLabel = UILabel(frame: CGRect(x: contentX, y: 0.025 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        bucketNameField = UITextField(frame: CGRect(x: contentX, y: 0.1 * innerHeight, width: contentWidth, height: contentHeight))
        nameLabel.backgroundColor = UIColor.clear
        nameLabel.text = "Bucket Name"
        nameLabel.font = UIFont(name: "Helvetica", size: 20)
        nameLabel.textColor = UIColor.white
        bucketNameField.backgroundColor = UIColor.black
        bucketNameField.textColor = UIColor.white
        bucketNameField.font = UIFont(name: "Helvetica", size: 25)
        bucketNameField.textAlignment = .center
        
        let limitLabel = UILabel(frame: CGRect(x: contentX, y: 0.225 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        bucketLimitField = UITextField(frame: CGRect(x: contentX, y: 0.3 * innerHeight, width: contentWidth, height: contentHeight))
        limitLabel.backgroundColor = UIColor.clear
        limitLabel.text = "Bucket Limit"
        limitLabel.font = UIFont(name: "Helvetica", size: 20)
        limitLabel.textColor = UIColor.white
        bucketLimitField.backgroundColor = UIColor.black
        bucketLimitField.textColor = UIColor.white
        bucketLimitField.keyboardType = .decimalPad
        bucketLimitField.font = UIFont(name: "Helvetica", size: 25)
        bucketLimitField.textAlignment = .center
        
        let colorSelectionLabel = UILabel(frame: CGRect(x: contentX, y: 0.425 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        colorSelectionLabel.text = "Color"
        colorSelectionLabel.backgroundColor = UIColor.clear
        colorSelectionLabel.textColor =  UIColor.white
        colorSelectionLabel.font = UIFont(name: "Helvetica", size: 20)
        colorTextField = UITextField(frame: CGRect(x: contentX, y: 0.5 * innerHeight, width: contentWidth, height: contentHeight))
        colorTextField.backgroundColor = UIColor.black
        colorTextField.text = defaultColor
        colorTextField.textAlignment = .center
        colorTextField.textColor = UIColor.white
        colorTextField.font = UIFont(name: "Helvetica", size: 25)
        colorTextField.inputView = colorPickerView
        
        innerDialogueView.addSubview(nameLabel)
        innerDialogueView.addSubview(bucketNameField)
        innerDialogueView.addSubview(limitLabel)
        innerDialogueView.addSubview(bucketLimitField)
        innerDialogueView.addSubview(colorSelectionLabel)
        innerDialogueView.addSubview(colorTextField)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    @objc func handleDatePicker(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        renewDateTextField.text = formatter.string(from: sender.date)
    }
    
    func setupBudgetDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{
        
        //bucketPickerView = UIPickerView(frame: CGRect(x: 0, y: screenHeight * 0.7, width: screenWidth, height: screenHeight * 0.3))
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: screenHeight * 0.7, width: screenWidth, height: screenHeight * 0.3))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        let dialogueView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dialogueView.backgroundColor = backgroundColorWithAlpha
        
        let innerWidth = (1 - innerViewXPortion * 2) * screenWidth
        let innerHeight = (1 - innerViewYPortion * 2) * screenHeight
        let innerViewX = innerViewXPortion * screenWidth
        let innerViewY = innerViewYPortion * screenHeight
        
        let innerDialogueView = UIView(frame: CGRect(x: innerViewX, y: innerViewY, width: innerWidth, height: innerHeight))
        innerDialogueView.backgroundColor = backgroundColor
        
        let bottomButtonY = innerHeight * 0.8
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        let confirmButton = UIButton(frame: CGRect(x: 0.5 * innerWidth, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
        confirmButton.setTitle("Confirm", for: UIControl.State.normal)
        
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        confirmButton.titleLabel?.textAlignment = .center
        confirmButton.titleLabel?.textColor = UIColor.white
        confirmButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        
        cancelButton.addTarget(self, action: #selector(ViewController.closeDialogue(_sender:)), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(ViewController.addBudget(_sender:)), for: .touchUpInside)
        
        innerDialogueView.addSubview(cancelButton)
        innerDialogueView.addSubview(confirmButton)
        
        let padding: CGFloat = 0.05
        let contentWidth = innerWidth * (1 - 2 * padding)
        let contentHeight = innerHeight * 0.1
        let contentX = innerWidth  * padding
        
        let amountLabel = UILabel(frame: CGRect(x: contentX, y: 0.025 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        budgetAmountField = UITextField(frame: CGRect(x: contentX, y: 0.1 * innerHeight, width: contentWidth, height: contentHeight))
        amountLabel.backgroundColor = UIColor.clear
        amountLabel.text = "Amount"
        amountLabel.font = UIFont(name: "Helvetica", size: 20)
        amountLabel.textColor = UIColor.white
        budgetAmountField.backgroundColor = UIColor.black
        budgetAmountField.textColor = UIColor.white
        budgetAmountField.keyboardType = .decimalPad
        budgetAmountField.font = UIFont(name: "Helvetica", size: 25)
        budgetAmountField.textAlignment = .center
        
        let renewDateLabel = UILabel(frame: CGRect(x: contentX, y: 0.225 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        renewDateTextField = UITextField(frame: CGRect(x: contentX, y: 0.3 * innerHeight, width: contentWidth, height: contentHeight))
        renewDateLabel.backgroundColor = UIColor.clear
        renewDateLabel.text = "Next Renew On"
        renewDateLabel.font = UIFont(name: "Helvetica", size: 20)
        renewDateLabel.textColor = UIColor.white
        renewDateTextField.backgroundColor = UIColor.black
        renewDateTextField.textColor = UIColor.white
        renewDateTextField.font = UIFont(name: "Helvetica", size: 25)
        renewDateTextField.textAlignment = .center
        renewDateTextField.inputView = datePicker
        
        let renewFrequencyLabel = UILabel(frame: CGRect(x: contentX, y: 0.425 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        renewFrequency = UITextField(frame: CGRect(x: contentX, y: 0.5 * innerHeight, width: contentWidth, height: contentHeight))
        renewFrequencyLabel.backgroundColor = UIColor.clear
        renewFrequencyLabel.text = "Renew Frequency"
        renewFrequencyLabel.font = UIFont(name: "Helvetica", size: 20)
        renewFrequencyLabel.textColor = UIColor.white
        renewFrequency.backgroundColor = UIColor.black
        renewFrequency.textColor = UIColor.white
        renewFrequency.keyboardType = .decimalPad
        renewFrequency.font = UIFont(name: "Helvetica", size: 25)
        renewFrequency.textAlignment = .center
        
        innerDialogueView.addSubview(amountLabel)
        innerDialogueView.addSubview(budgetAmountField)
        innerDialogueView.addSubview(renewDateLabel)
        innerDialogueView.addSubview(renewDateTextField)
        innerDialogueView.addSubview(renewFrequencyLabel)
        innerDialogueView.addSubview(renewFrequency)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    func setupTransactionDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{
        bucketPickerView = UIPickerView(frame: CGRect(x: 0, y: screenHeight * 0.7, width: screenWidth, height: screenHeight * 0.3))
        //bucketPickerView.isHidden = true
        bucketPickerView.delegate = self
        bucketPickerView.dataSource = self
        bucketPickerView.backgroundColor = backgroundColorWithAlpha
        
        let dialogueView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dialogueView.backgroundColor = backgroundColorWithAlpha
        
        let innerWidth = (1 - innerViewXPortion * 2) * screenWidth
        let innerHeight = (1 - innerViewYPortion * 2) * screenHeight
        let innerViewX = innerViewXPortion * screenWidth
        let innerViewY = innerViewYPortion * screenHeight
        
        let innerDialogueView = UIView(frame: CGRect(x: innerViewX, y: innerViewY, width: innerWidth, height: innerHeight))
        innerDialogueView.backgroundColor = backgroundColor
        
        let bottomButtonY = innerHeight * 0.8
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        let confirmButton = UIButton(frame: CGRect(x: 0.5 * innerWidth, y: bottomButtonY, width: innerWidth * 0.5, height: innerHeight * 0.2))
        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
        confirmButton.setTitle("Confirm", for: UIControl.State.normal)
        
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        confirmButton.titleLabel?.textAlignment = .center
        confirmButton.titleLabel?.textColor = UIColor.white
        confirmButton.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
        
        cancelButton.addTarget(self, action: #selector(ViewController.closeDialogue(_sender:)), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(ViewController.addTransaction(_sender:)), for: .touchUpInside)
        
        innerDialogueView.addSubview(cancelButton)
        innerDialogueView.addSubview(confirmButton)
        
        let padding: CGFloat = 0.05
        let contentWidth = innerWidth * (1 - 2 * padding)
        let contentHeight = innerHeight * 0.1
        let contentX = innerWidth  * padding
        
        let amountLabel = UILabel(frame: CGRect(x: contentX, y: 0.025 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        amountField = UITextField(frame: CGRect(x: contentX, y: 0.1 * innerHeight, width: contentWidth, height: contentHeight))
        amountLabel.backgroundColor = UIColor.clear
        amountLabel.text = "Amount"
        amountLabel.font = UIFont(name: "Helvetica", size: 20)
        amountLabel.textColor = UIColor.white
        amountField.backgroundColor = UIColor.black
        amountField.textColor = UIColor.white
        amountField.keyboardType = .decimalPad
        amountField.font = UIFont(name: "Helvetica", size: 25)
        amountField.textAlignment = .center
        
        let bucketSelectionLabel = UILabel(frame: CGRect(x: contentX, y: 0.225 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        bucketSelectionLabel.text = "Bucket"
        bucketSelectionLabel.backgroundColor = UIColor.clear
        bucketSelectionLabel.textColor =  UIColor.white
        bucketSelectionLabel.font = UIFont(name: "Helvetica", size: 20)
        bucketTextField = UITextField(frame: CGRect(x: contentX, y: 0.3 * innerHeight, width: contentWidth, height: contentHeight))
        bucketTextField.backgroundColor = UIColor.black
        bucketTextField.text = defaultBucketName
        bucketTextField.textAlignment = .center
        bucketTextField.textColor = UIColor.white
        bucketTextField.font = UIFont(name: "Helvetica", size: 25)
        bucketTextField.inputView = bucketPickerView
        
        let descriptionLabel = UILabel(frame: CGRect(x: contentX, y: 0.425 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        descriptionLabel.text = "Description"
        descriptionLabel.backgroundColor = UIColor.clear
        descriptionLabel.textColor =  UIColor.white
        descriptionLabel.font = UIFont(name: "Helvetica", size: 20)
        
        descriptionField = UITextField(frame: CGRect(x: contentX, y: 0.5 * innerHeight, width: contentWidth, height: contentHeight))
        descriptionField.backgroundColor = UIColor.black
        descriptionField.textColor = UIColor.white
        descriptionField.font = UIFont(name: "Helvetica", size: 25)
        
        innerDialogueView.addSubview(amountLabel)
        innerDialogueView.addSubview(amountField)
        innerDialogueView.addSubview(bucketSelectionLabel)
        innerDialogueView.addSubview(bucketTextField)
        innerDialogueView.addSubview(descriptionLabel)
        innerDialogueView.addSubview(descriptionField)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    func setTopDisplay(totalBudget: Double, totalSpending: Double){
        if (totalSpending > totalBudget){
            topDisplayField.textColor = badColor
        }else{
            topDisplayField.textColor = okayColor
        }
        topDisplayField.font = UIFont(name: "Helvetica", size: 40)
        topDisplayField.text = String(format: "%.2f/%.2f", totalSpending, totalBudget)
    }
    func setupTopView(screenWidth: CGFloat, screenHeight: CGFloat, totalBudget: Double, totalSpending: Double){
        let topViewWidth = screenWidth
        let topViewHeight = screenHeight * topViewPortion
        let topViewColor = backgroundColor
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: topViewWidth, height: topViewHeight))
        topView.backgroundColor = topViewColor
        
        topDisplayField = UILabel(frame: CGRect(x: 0.1 * topViewWidth, y: 0.3 * topViewHeight, width: 0.8 * topViewWidth, height: 0.4 * topViewHeight))
        topDisplayField.textAlignment = .center
        setTopDisplay(totalBudget: totalBudget, totalSpending: totalSpending)
        topView.addSubview(topDisplayField)
        
        let addButton = UIButton(frame: CGRect(x: 0.9 * topViewWidth, y: 0.1 * topViewHeight, width: 0.1 * topViewWidth, height: 0.1 * topViewWidth))
        addButton.setTitle("+", for: UIControl.State.normal)
        addButton.titleLabel?.textAlignment = .center
        addButton.titleLabel?.textColor = UIColor.white
        addButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        addButton.addTarget(self, action: #selector(ViewController.addClicked(_sender:)), for: .touchUpInside)
        topView.addSubview(addButton)
        
        let addBucketButton = UIButton(frame: CGRect(x: 0.7 * topViewWidth, y: 0.8 * topViewHeight, width: 0.3 * topViewWidth, height: 0.1 * topViewWidth))
        addBucketButton.setTitle("Add Bucket", for: UIControl.State.normal)
        addBucketButton.titleLabel?.textAlignment = .center
        addBucketButton.titleLabel?.textColor = UIColor.white
        addBucketButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        addBucketButton.addTarget(self, action: #selector(ViewController.addBucketClicked(_sender:)), for: .touchUpInside)
        
        let budgetButton = UIButton(frame: CGRect(x: 0 * topViewWidth, y: 0.8 * topViewHeight, width: 0.3 * topViewWidth, height: 0.1 * topViewWidth))
        budgetButton.setTitle("Budget", for: UIControl.State.normal)
        budgetButton.titleLabel?.textAlignment = .center
        budgetButton.titleLabel?.textColor = UIColor.white
        budgetButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        budgetButton.addTarget(self, action: #selector(ViewController.budgetClicked(_sender:)), for: .touchUpInside)
        topView.addSubview(addButton)
        topView.addSubview(addBucketButton)
        topView.addSubview(budgetButton)
        self.view.addSubview(topView)
    }
    
    func setupTableView(screenWidth: CGFloat,screenHeight: CGFloat, buckets: [Bucket]){
        let tableViewWidth = screenWidth
        let tableViewHeight = screenHeight * (1 - topViewPortion)
        let tableViewY = screenHeight * topViewPortion
        
        tableView = UITableView(frame: CGRect(x: 0, y: tableViewY, width: tableViewWidth, height: tableViewHeight))
        tableView.backgroundColor = backgroundColor
        tableView.separatorColor = backgroundColorWithAlpha
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBuckets.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)

        // set the text from the data model
        let cellRect = cell.bounds
        let cellWidth = tableView.bounds.width
        let cellHeight = cellRect.size.height
        
        let titleView = UILabel(frame: CGRect(x: 0.05 * cellWidth, y: 0, width: cellWidth * 0.45, height: cellHeight))
        let summaryView = UILabel(frame: CGRect(x: cellWidth * 0.5, y: 0, width: cellWidth * 0.45, height: cellHeight))
        let bucket = self.allBuckets[indexPath.row]
        titleView.text = bucket.name
        titleView.textColor = UIColor.black
        titleView.backgroundColor = UIColor.clear
        titleView.textAlignment = .left
        let budget = bucket.budget
        let spending = bucket.spending
        summaryView.text = String(format: "%.2f/%.2f", spending, budget)
        summaryView.textAlignment = .right
        summaryView.backgroundColor = UIColor.clear
        summaryView.textColor = UIColor.black
        cell.addSubview(titleView)
        cell.addSubview(summaryView)
        let bucketColor = UIColor(hue: bucket.hue, saturation: bucket.saturation, brightness: bucket.brightness, alpha: 100)
        cell.backgroundColor = bucketColor
        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        let tappedBucket = allBuckets[indexPath.row].name
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableCellSelected(name: tappedBucket)
    }
    
    func tableCellSelected(name: String){
        print("in segue")
        let nextViewController = BucketViewController()
        nextViewController.bucketName = name
        nextViewController.bucketModel = self.bucketModel
        nextViewController.mainViewController = self
        nextViewController.allBuckets = self.allBuckets
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if(pickerView == bucketPickerView){
            return self.allBuckets.count
        }else{
            return self.colorDictionary.count
        }
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == bucketPickerView){
            return self.allBuckets[row].name
        }else{
            return Array(self.colorDictionary.keys)[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == bucketPickerView){
            self.bucketTextField.text = self.allBuckets[row].name
        }else{
            self.colorTextField.text = Array(self.colorDictionary.keys)[row]
        }
    }
}

