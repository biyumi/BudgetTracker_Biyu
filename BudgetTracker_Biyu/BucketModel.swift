//
//  BucketModel.swift
//  BudgetTracker_Biyu
//
//  Created by Biyu Mi on 2/15/20.
//  Copyright © 2020 Biyu Mi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct Transaction: Codable{
    var amount: Double
    var description: String
    var time: Date
}

struct Bucket: Codable{
    var name: String
    var budget: Double
    var spending: Double
    var hue: CGFloat
    var brightness: CGFloat
    var saturation: CGFloat
    var transactions: [Transaction]
}

struct BucketData: Codable{
    var totalBudget: Double
    var totalSpending: Double
    var renewDate: String
    var renewFrequency: Int
//    var renewDate: Date
//    var renewInterval: Int
    var buckets: [Bucket]
}

class BucketModel:bucketDelegate, bucketModelDelegate{

    var bucketData:BucketData!
    var buckets:[Bucket] =  []
    var totalBudget:Double = 0
    var renewDate:String = ""
    var renewFrequency: Int = 30
    
    let fm = FileManager()
    
    func fetchAllData() -> BucketData{
        if (bucketData == nil){
            if(!self.getData()){
                updateData()
            }
            self.renewDate = bucketData.renewDate
            self.renewFrequency = bucketData.renewFrequency
            self.totalBudget = bucketData.totalBudget
            self.buckets = bucketData.buckets
        }
        
        if(self.renewDate != ""){
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.date(from:self.renewDate)!
            if(today > date){
                let timeIntervalInSeconds:Double = Double(self.renewFrequency * 24 * 60 * 60)
                self.renewDate = dateFormatter.string(from: date.addingTimeInterval(timeIntervalInSeconds))
                self.clearTransactions()
                _=self.saveData()
            }
        }
        return self.bucketData
    }
    
    func clearTransactions(){
        for (index, _) in buckets.enumerated(){
            buckets[index].spending = 0
            buckets[index].transactions = []
            buckets[index].saturation = 0.2
        }
    }
    
    func updateData(){
        var totalSpending:Double = 0
        for b in buckets{
            totalSpending += b.spending
        }
        self.bucketData = BucketData(totalBudget:totalBudget, totalSpending:totalSpending, renewDate:renewDate, renewFrequency:renewFrequency, buckets:buckets)
    }
    
    func FetchBucketData(name: String) -> Bucket{
        for (_, b) in self.buckets.enumerated() {
            if (b.name == name){
                return b
            }
        }
        return Bucket(name: "", budget: 0, spending: 0, hue: 0, brightness: 0, saturation: 0, transactions: [])
    }
        
    func calcSaturation(percentage: Double) -> CGFloat{
        let newSaturation = CGFloat(0.2 + 0.8*percentage)
        return newSaturation
        //return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: 1)
    }
    
    func addBucket(name: String, limit: Double, defaultBucketName:String, hue:CGFloat, brightness:CGFloat) -> Bool{
        
        let saturation = calcSaturation(percentage: 0)
        if(self.buckets.count > 0){
            for (index, b) in self.buckets.enumerated() {
                if (b.name == defaultBucketName){
                    if(limit <= self.buckets[index].budget){
                        self.buckets[index].budget -= limit
                        self.buckets.append(Bucket(name: name, budget: limit, spending: 0, hue: hue, brightness: brightness, saturation: saturation, transactions: []))
                        return saveData()
                    }else{
                        return false
                    }
                }
            }
            return false
        }else{
            self.buckets.append(Bucket(name: name, budget: limit, spending: 0, hue: hue, brightness: brightness, saturation: 0.2, transactions: []))
            return saveData()
        }
    }
    
    func removeBucket(bucket: String) -> Bool{
        var budget:Double = 0
        for (index, b) in self.buckets.enumerated() {
            if (b.name == bucket){
                budget = self.buckets[index].budget
                self.buckets.remove(at: index)
            }
        }
        
        for (index, b) in self.buckets.enumerated() {
            if (b.name == "other"){
                self.buckets[index].budget += budget
            }
        }
        return saveData()
    }
    
    func removeTransaction(amount: Double, bucket: String, description: String) -> Bool{
        for (index, b) in self.buckets.enumerated() {
            if (b.name == bucket){
                self.buckets[index].spending -= amount
                for (i, c) in self.buckets[index].transactions.enumerated(){
                    if (c.description == description && c.amount == amount){
                        self.buckets[index].transactions.remove(at: i)
                    }
                }
                let percentage = self.buckets[index].spending / self.buckets[index].budget
                let newSaturation = calcSaturation(percentage: percentage)
                self.buckets[index].saturation = newSaturation
            }
        }
        return saveData()
    }
    
    func addTransaction(amount: Double, bucket: String, description: String) -> Bool{
        for (index, b) in self.buckets.enumerated() {
            if (b.name == bucket){
                self.buckets[index].spending += amount
                self.buckets[index].transactions.append(Transaction(amount: amount, description: description, time: Date()))
                let percentage = self.buckets[index].spending / self.buckets[index].budget
                let newSaturation = calcSaturation(percentage: percentage)
                self.buckets[index].saturation = newSaturation
            }
        }
        return saveData()
    }
    
    func addBudget(amount: Double, defaultBucketName:String, renewDate:String, renewFrequency:Int) -> Bool{
        let difference = amount - totalBudget
        self.totalBudget = amount
        self.renewDate = renewDate
        self.renewFrequency = renewFrequency
        if(self.buckets.count == 0){
            return self.addBucket(name: defaultBucketName, limit: amount, defaultBucketName: defaultBucketName, hue: 0, brightness: 1)
        }else{
            for (index, b) in self.buckets.enumerated() {
                if (b.name == defaultBucketName){
                    self.buckets[index].budget += difference
                }
            }
            return saveData()
        }
    }
    
    func saveData() -> Bool{
        updateData()
        guard let mainUrl = Bundle.main.url(forResource: "save", withExtension: "json") else { return false}
                
        writeToFile(location: mainUrl)
        return true
    }
    
    func getData() -> Bool{
        guard let mainUrl = Bundle.main.url(forResource: "save", withExtension: "json") else { return false}
                
        return loadFile(mainPath: mainUrl)
    }
    
    func loadFile(mainPath: URL) -> Bool{
        decodeData(pathName: mainPath)
        
        return bucketData != nil
    }
    
    func decodeData(pathName: URL){
        do{
            let jsonData = try Data(contentsOf: pathName)
            let decoder = JSONDecoder()
            bucketData = try decoder.decode(BucketData.self, from: jsonData)
        } catch {}
    }
    
    func writeToFile(location: URL) {
        do{
            print(location)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let JsonData = try encoder.encode(bucketData)
            try JsonData.write(to: location)
        }catch{}
    }
}
