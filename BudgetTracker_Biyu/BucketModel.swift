//
//  BucketModel.swift
//  BudgetTracker_Biyu
//
//  Created by Zehao Zhang on 2/15/20.
//  Copyright © 2020 Biyu Mi. All rights reserved.
//

import Foundation
import CoreData

struct Bucket{
    var name: String
    var budget: Double
    var spending: Double
}

struct BucketData{
    var totalBudget: Double
    var totalSpending: Double
    var buckets: [Bucket]
}

class BucketModel:bucketDelegate{
    
    var buckets:[Bucket] =  []
    
    func fetchAllData() -> BucketData{
        var totalBudget:Double = 0
        var totalSpending:Double = 0
        for b in buckets{
            totalBudget += b.budget
            totalSpending += b.spending
        }
        let data = BucketData(totalBudget:totalBudget, totalSpending:totalSpending, buckets:buckets)
        return data
    }
    
    func addBucket(name: String, limit: Double) -> Bool{
        self.buckets.append(Bucket(name: name, budget: limit, spending: 0))
        return true
    }
    
    func addTransaction(amount: Double, bucket: String, description: String) -> Bool{
        for (index, b) in self.buckets.enumerated() {
            if (b.name == bucket){
                self.buckets[index].spending += amount
            }
        }
        return true
    }
    
    func addBudget(amount: Double, defaultBucketName:String) -> Bool{
        if(self.buckets.count == 0){
            return self.addBucket(name: defaultBucketName, limit: amount)
        }else{
            for (index, b) in self.buckets.enumerated() {
                if (b.name == defaultBucketName){
                    self.buckets[index].budget += amount
                }
            }
            return true
        }
    }
}
