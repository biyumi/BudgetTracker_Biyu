//
//  BucketViewController.swift
//  BudgetTracker_Biyu
//
//  Created by Zehao Zhang on 4/4/20.
//  Copyright © 2020 Biyu Mi. All rights reserved.
//

import UIKit
import CoreData

protocol bucketModelDelegate {
    func FetchBucketData(name: String) -> Bucket
    func addTransaction(amount: Double, bucket: String, description: String) -> Bool
    func removeTransaction(amount: Double, bucket: String, description: String) -> Bool
    func removeBucket(bucket: String) -> Bool
}

class BucketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let topViewPortion: CGFloat = 0.3
    let innerViewYPortion: CGFloat = 0.2
    let innerViewXPortion: CGFloat = 0.1
    let backgroundColor = UIColor.init(hue: 1, saturation: 0, brightness: 0.17, alpha: 1)
    let backgroundColorWithAlpha = UIColor.init(hue: 1, saturation: 0, brightness: 0.39, alpha: 0.8)
    let okayColor = UIColor.init(hue: 0.43, saturation: 1, brightness: 0.7, alpha: 1)
    let badColor = UIColor.init(hue: 0, saturation: 1, brightness: 0.6, alpha: 1)
    
    let cellReuseIdentifier = "cell"
    let defaultBucketName  = "other"
    let defaultDeleteAll = "Delete all transactions"
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var delegate: bucketModelDelegate?
    
    var bucketName = ""
    var bucketModel:BucketModel = BucketModel()
    
    var transactions: [Transaction] = []
    var allBuckets: [Bucket] = []

    var totalBudget:Double = 0
    var totalSpending:Double = 0
    var bucketColor:UIColor = UIColor.red
    
    var mainViewController:ViewController!
    
    var selectedTransaction: Transaction!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bucketPickerView: UIPickerView!
    @IBOutlet var bucketPickerView2: UIPickerView!
    @IBOutlet var bucketTextField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var editAmountField: UITextField!
    @IBOutlet var editDescriptionField: UITextField!
    @IBOutlet var editBucketTextField: UITextField!
    @IBOutlet var addTransactionDialogueView: UIView!
    @IBOutlet var editTransactionDialogueView: UIView!
    @IBOutlet var deleteBucketView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var topDisplayField: UILabel!
    
    @IBAction func backButtonClicked(_sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addClicked(_sender: UIButton!){
        self.addTransactionDialogueView.isHidden = false
    }
    
    @IBAction func closeDialogue(_sender: Any){
        self.addTransactionDialogueView.isHidden = true
        self.deleteBucketView.isHidden = true
        self.editTransactionDialogueView.isHidden = true
    }
    
    @IBAction func deleteBucketClicked(_sender: Any){
        self.deleteBucketView.isHidden = false
    }
    
    @IBAction func editTransaction(_sender: Any){
        let transferBucket = editBucketTextField.text!
        let amount = Double(editAmountField.text!)!
        let description = editDescriptionField.text!
        let deleteSuccess=self.delegate?.removeTransaction(amount: selectedTransaction.amount, bucket: self.bucketName, description: selectedTransaction.description)
        let addSuccess=self.delegate?.addTransaction(amount: amount, bucket: transferBucket, description: description)
        if(deleteSuccess! && addSuccess!){
            resetData()
            self.editTransactionDialogueView.isHidden = true
        }
    }
    
    func transactionClicked(transaction: Transaction){
        self.selectedTransaction = transaction
        self.editAmountField.text = String(transaction.amount)
        self.editDescriptionField.text = transaction.description
        self.editBucketTextField.text = self.bucketName
        self.editTransactionDialogueView.isHidden = false
    }
    
    func resetInput(){
        self.amountField.text = ""
        self.descriptionField.text = ""
    }
    
    func resetData(){
        let data = self.delegate!.FetchBucketData(name: bucketName)
        transactions = data.transactions
        totalBudget = data.budget
        totalSpending = data.spending
        bucketColor = UIColor(hue: data.hue, saturation: data.saturation, brightness: data.brightness, alpha: 100)
        self.tableView.reloadData()
        self.setTopDisplay(totalBudget: totalBudget, totalSpending: totalSpending)
        self.mainViewController.resetData()
    }
    
    @IBAction func addTransaction(_sender: Any){
        let transAmount = Double(amountField.text!)!
        let description =  descriptionField.text!
        let bucket = self.bucketName
        let success = self.delegate?.addTransaction(amount: transAmount, bucket: bucket, description: description)
        if(success!){
            resetData()
        }
        self.resetInput()
        self.addTransactionDialogueView.isHidden = true
    }
    
    @IBAction func deleteBucket(_sender: Any){
        let transferBucket = bucketTextField.text!
        if (transferBucket != defaultDeleteAll){
            for t in transactions{
                _ = self.delegate?.addTransaction(amount: t.amount, bucket: transferBucket, description: t.description)
            }
        }
        let success = self.delegate?.removeBucket(bucket: bucketName)
        if(success!){
            resetData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        print("tap")
    }
    
    override func loadView() {
        super.loadView()
        self.delegate = bucketModel
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let data = self.delegate!.FetchBucketData(name: bucketName)
        transactions = data.transactions
        totalBudget = data.budget
        totalSpending = data.spending
        bucketColor = UIColor(hue: data.hue, saturation: data.saturation, brightness: data.brightness, alpha: 100)
        self.setupTopView(screenWidth: screenWidth, screenHeight: screenHeight, totalBudget: totalBudget, totalSpending: totalSpending)
        self.setupTableView(screenWidth: screenWidth, screenHeight: screenHeight, transactions: transactions)
        addTransactionDialogueView = self.setupTransactionDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        deleteBucketView = self.setupDeleteDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        editTransactionDialogueView  = self.setUpEditTransactionDialogue(screenWidth: screenWidth, screenHeight: screenHeight)
        self.view.addSubview(addTransactionDialogueView)
        self.view.addSubview(deleteBucketView)
        self.view.addSubview(editTransactionDialogueView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.addTransactionDialogueView.addGestureRecognizer(tap1)
        
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.deleteBucketView.addGestureRecognizer(tap2)
        
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.editTransactionDialogueView.addGestureRecognizer(tap3)
    }
    
    func setTopDisplay(totalBudget: Double, totalSpending: Double){
        topDisplayField.textColor = UIColor.black
        topDisplayField.font = UIFont(name: "Helvetica", size: 40)
        topDisplayField.text = String(format: "%.2f/%.2f", totalSpending, totalBudget)
        topView.backgroundColor = bucketColor
    }
    func setupTopView(screenWidth: CGFloat, screenHeight: CGFloat, totalBudget: Double, totalSpending: Double){
        let topViewWidth = screenWidth
        let topViewHeight = screenHeight * topViewPortion
        let topViewColor = bucketColor
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: topViewWidth, height: topViewHeight))
        topView.backgroundColor = topViewColor
        
        topDisplayField = UILabel(frame: CGRect(x: 0.1 * topViewWidth, y: 0.3 * topViewHeight, width: 0.8 * topViewWidth, height: 0.4 * topViewHeight))
        topDisplayField.textAlignment = .center
        setTopDisplay(totalBudget: totalBudget, totalSpending: totalSpending)
        topView.addSubview(topDisplayField)
        
        let addButton = UIButton(frame: CGRect(x: 0.9 * topViewWidth, y: 0.1 * topViewHeight, width: 0.1 * topViewWidth, height: 0.1 * topViewWidth))
        addButton.setTitle("+", for: UIControl.State.normal)
        addButton.titleLabel?.textAlignment = .center
        addButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        addButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        addButton.addTarget(self, action: #selector(BucketViewController.addClicked(_sender:)), for: .touchUpInside)
        topView.addSubview(addButton)
        
        let backButton = UIButton(frame: CGRect(x: 0.025 * topViewWidth, y: 0.1 * topViewHeight, width: 0.2 * topViewWidth, height: 0.1 * topViewWidth))
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel?.textAlignment = .center
        backButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        backButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(BucketViewController.backButtonClicked(_sender:)), for: .touchUpInside)
        if(self.bucketName != defaultBucketName){
            let deleteBucketButton = UIButton(frame: CGRect(x: 0.7 * topViewWidth, y: 0.8 * topViewHeight, width: 0.3 * topViewWidth, height: 0.1 * topViewWidth))
            deleteBucketButton.setTitle("Delete", for: UIControl.State.normal)
            deleteBucketButton.titleLabel?.textAlignment = .right
            deleteBucketButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            deleteBucketButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
            deleteBucketButton.addTarget(self, action: #selector(BucketViewController.deleteBucketClicked(_sender:)), for: .touchUpInside)
            topView.addSubview(deleteBucketButton)
        }
        
        topView.addSubview(addButton)
        topView.addSubview(backButton)
        self.view.addSubview(topView)
    }
    
    func setupDeleteDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{
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
        
        cancelButton.addTarget(self, action: #selector(BucketViewController.closeDialogue(_sender:)), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(BucketViewController.deleteBucket(_sender:)), for: .touchUpInside)
        
        innerDialogueView.addSubview(cancelButton)
        innerDialogueView.addSubview(confirmButton)
        
        let padding: CGFloat = 0.05
        let contentWidth = innerWidth * (1 - 2 * padding)
        let contentHeight = innerHeight * 0.1
        let contentX = innerWidth  * padding
        
        
        let bucketSelectionLabel = UILabel(frame: CGRect(x: contentX, y: 0.025 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        bucketSelectionLabel.text = "Transfer to Bucket"
        bucketSelectionLabel.backgroundColor = UIColor.clear
        bucketSelectionLabel.textColor =  UIColor.white
        bucketSelectionLabel.font = UIFont(name: "Helvetica", size: 20)
        bucketTextField = UITextField(frame: CGRect(x: contentX, y: 0.1 * innerHeight, width: contentWidth, height: contentHeight))
        bucketTextField.backgroundColor = UIColor.black
        bucketTextField.text = defaultDeleteAll
        bucketTextField.textAlignment = .center
        bucketTextField.textColor = UIColor.white
        bucketTextField.font = UIFont(name: "Helvetica", size: 25)
        bucketTextField.inputView = bucketPickerView

        innerDialogueView.addSubview(bucketSelectionLabel)
        innerDialogueView.addSubview(bucketTextField)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    func setUpEditTransactionDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{
        bucketPickerView2 = UIPickerView(frame: CGRect(x: 0, y: screenHeight * 0.7, width: screenWidth, height: screenHeight * 0.3))
        //bucketPickerView.isHidden = true
        bucketPickerView2.delegate = self
        bucketPickerView2.dataSource = self
        bucketPickerView2.backgroundColor = backgroundColorWithAlpha
        
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
        
        confirmButton.addTarget(self, action: #selector(BucketViewController.editTransaction(_sender:)), for: .touchUpInside)
        
        innerDialogueView.addSubview(cancelButton)
        innerDialogueView.addSubview(confirmButton)
        
        let padding: CGFloat = 0.05
        let contentWidth = innerWidth * (1 - 2 * padding)
        let contentHeight = innerHeight * 0.1
        let contentX = innerWidth  * padding
        
        let amountLabel = UILabel(frame: CGRect(x: contentX, y: 0.025 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        editAmountField = UITextField(frame: CGRect(x: contentX, y: 0.1 * innerHeight, width: contentWidth, height: contentHeight))
        amountLabel.backgroundColor = UIColor.clear
        amountLabel.text = "Amount"
        amountLabel.font = UIFont(name: "Helvetica", size: 20)
        amountLabel.textColor = UIColor.white
        editAmountField.backgroundColor = UIColor.black
        editAmountField.textColor = UIColor.white
        editAmountField.keyboardType = .decimalPad
        editAmountField.font = UIFont(name: "Helvetica", size: 25)
        editAmountField.textAlignment = .center
        
        let bucketSelectionLabel = UILabel(frame: CGRect(x: contentX, y: 0.225 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        bucketSelectionLabel.text = "Bucket"
        bucketSelectionLabel.backgroundColor = UIColor.clear
        bucketSelectionLabel.textColor =  UIColor.white
        bucketSelectionLabel.font = UIFont(name: "Helvetica", size: 20)
        editBucketTextField = UITextField(frame: CGRect(x: contentX, y: 0.3 * innerHeight, width: contentWidth, height: contentHeight))
        editBucketTextField.backgroundColor = UIColor.black
        editBucketTextField.text = defaultBucketName
        editBucketTextField.textAlignment = .center
        editBucketTextField.textColor = UIColor.white
        editBucketTextField.font = UIFont(name: "Helvetica", size: 25)
        editBucketTextField.inputView = bucketPickerView2
        
        let descriptionLabel = UILabel(frame: CGRect(x: contentX, y: 0.425 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        descriptionLabel.text = "Description"
        descriptionLabel.backgroundColor = UIColor.clear
        descriptionLabel.textColor =  UIColor.white
        descriptionLabel.font = UIFont(name: "Helvetica", size: 20)
        
        editDescriptionField = UITextField(frame: CGRect(x: contentX, y: 0.5 * innerHeight, width: contentWidth, height: contentHeight))
        editDescriptionField.backgroundColor = UIColor.black
        editDescriptionField.textColor = UIColor.white
        editDescriptionField.font = UIFont(name: "Helvetica", size: 25)
        
        innerDialogueView.addSubview(amountLabel)
        innerDialogueView.addSubview(editAmountField)
        innerDialogueView.addSubview(bucketSelectionLabel)
        innerDialogueView.addSubview(editBucketTextField)
        innerDialogueView.addSubview(descriptionLabel)
        innerDialogueView.addSubview(editDescriptionField)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    func setupTransactionDialogue(screenWidth: CGFloat, screenHeight: CGFloat) -> UIView{        
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
        
        cancelButton.addTarget(self, action: #selector(BucketViewController.closeDialogue(_sender:)), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(BucketViewController.addTransaction(_sender:)), for: .touchUpInside)
        
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
        
        let descriptionLabel = UILabel(frame: CGRect(x: contentX, y: 0.225 * innerHeight, width: contentWidth, height: contentHeight * 0.75))
        descriptionLabel.text = "Description"
        descriptionLabel.backgroundColor = UIColor.clear
        descriptionLabel.textColor =  UIColor.white
        descriptionLabel.font = UIFont(name: "Helvetica", size: 20)
        
        descriptionField = UITextField(frame: CGRect(x: contentX, y: 0.3 * innerHeight, width: contentWidth, height: contentHeight))
        descriptionField.backgroundColor = UIColor.black
        descriptionField.textColor = UIColor.white
        descriptionField.font = UIFont(name: "Helvetica", size: 25)
        
        innerDialogueView.addSubview(amountLabel)
        innerDialogueView.addSubview(amountField)
        innerDialogueView.addSubview(descriptionLabel)
        innerDialogueView.addSubview(descriptionField)
        dialogueView.addSubview(innerDialogueView)
        dialogueView.isHidden = true
        
        return dialogueView
    }
    
    func setupTableView(screenWidth: CGFloat,screenHeight: CGFloat, transactions: [Transaction]){
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
        return self.transactions.count
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
        let transaction = self.transactions[indexPath.row]
        titleView.text = transaction.description
        titleView.textColor = UIColor.white
        titleView.backgroundColor = UIColor.clear
        titleView.textAlignment = .left
        let amount = transaction.amount
        summaryView.text = String(format: "%.2f", amount)
        summaryView.textAlignment = .right
        summaryView.textColor = UIColor.white
        summaryView.backgroundColor = UIColor.clear
        cell.addSubview(titleView)
        cell.addSubview(summaryView)
        cell.backgroundColor = self.backgroundColor
        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        let selectedTransaction = transactions[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.transactionClicked(transaction: selectedTransaction)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.allBuckets.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allBuckets[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == bucketPickerView){
            self.bucketTextField.text = self.allBuckets[row].name
        }else{
            self.editBucketTextField.text = self.allBuckets[row].name
        }
        
    }
}
