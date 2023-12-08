//
//  DataModel.swift
//  callendarTrains
//
//  Created by Egor Ivanov on 28.04.2023.
//

import Foundation
import CoreData

class DataModel : ObservableObject {
    @Published var workDays : [MarkedDays] = []
    @Published var userProfile : [UserProfile] = []
    @Published var dailyPlans : [NewTasks] = []
    @Published var dailySpents : [DailySpents] = []
    let container = NSPersistentContainer(name: "DataModel")
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error.localizedDescription, "Not able to init the coredata")
            }
        }
        fetchMarkedDays()
        fetchUserProfile()
        fetchDailyTasks()
        fetchDailySpents()
        // Fetching data from bases
    }
    
    func fetchDailySpents() -> Void {
        let spentsRequest = NSFetchRequest<DailySpents>(entityName: "DailySpents")
        do {
            dailySpents = try container.viewContext.fetch(spentsRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchDailyTasks() -> Void {
        let dailyRequest = NSFetchRequest<NewTasks>(entityName: "NewTasks")
        do {
            dailyPlans = try container.viewContext.fetch(dailyRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUserProfile() -> Void {
        let profileRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        do {
            userProfile = try container.viewContext.fetch(profileRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchMarkedDays() -> Void {
        let daysRequest = NSFetchRequest<MarkedDays>(entityName: "MarkedDays")
        do {
            workDays = try container.viewContext.fetch(daysRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func save() -> Void {
        do {
            try container.viewContext.save()
            print("Data is saved")
            // Fetching Data.
            fetchDailySpents()
            fetchMarkedDays()
            fetchUserProfile()
            fetchDailyTasks()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func addSpents(nameOfSpent : String, costage : Int) -> Void {
        let date = Date()
        let calendar = Calendar.current
        let dailySpentObject = DailySpents(context: container.viewContext)
        dailySpentObject.id = UUID()
        dailySpentObject.costage = Int32(costage)
        dailySpentObject.name = nameOfSpent
        dailySpentObject.dayNumber = Int16(calendar.component(.day, from: date))
        dailySpentObject.monthNumber = Int16(calendar.component(.month, from: date))
        dailySpentObject.year = Int16(calendar.component(.year, from: date))
        dailySpents.append(dailySpentObject)
        print(dailySpents)
        save()
        
    }
    
    func removeByIndexSpents(element : DailySpents) -> Void {
        for (index, search) in dailySpents.enumerated() {
            if search == element {
                let removableobject = dailySpents[index]
                dailySpents.remove(at: index)
                container.viewContext.delete(removableobject)
                save()
            }
        }
    }
    
    func removeDayData(dayNum : Int) -> Void {
        let answer = findDay(number: dayNum)
        if answer.1 {
            let removableDay = dailyPlans[answer.0]
            dailyPlans.remove(at: answer.0)
            container.viewContext.delete(removableDay)
            save()
        }
    }
    
    func removeSelectedTask(array : [String], indexRemove : Int, selectedDay : Int) -> Void {
        var newArray = array
        newArray.remove(at: indexRemove)
        var stringSetUp : String = ""
        for elements in newArray {
            switch stringSetUp {
            case "":
                stringSetUp += elements
            default:
                stringSetUp += "|"
                stringSetUp += elements
            }
        }
        let indexArray = findDay(number: selectedDay).0
        dailyPlans[indexArray].taskArray = stringSetUp
        print(dailyPlans)
        save()
    }
    
    func addTasktoDay(dayNum : Int, task : String) -> Void {
        let answer = findDay(number: dayNum)
        if answer.1 {
            guard dailyPlans[answer.0].taskArray! != "" else {
                dailyPlans[answer.0].taskArray! += task
                print(dailyPlans)
                save()
                return
            }
            dailyPlans[answer.0].taskArray! += "|"
            dailyPlans[answer.0].taskArray! += task
            print(dailyPlans)
            save()
        }
    }
    
//    func removeTaskDay(indexTask : Int, indexDay : Int) -> Void {
//        let removableTask = dailyPlans[indexDay].tasksArray![indexTask]
//        dailyPlans[indexDay].tasksArray!.remove(at: indexTask)
//        container.viewContext.delete(removableTask)
//        save()
//    }
    
    func findDay(number : Int) -> (Int, Bool) {
        var found : Bool = false
        var returnIndex = 0
        for search in dailyPlans {
            if number == search.dayNum {
                found = true
                print(returnIndex, found)
                return (returnIndex, found)
            }
            else {
                returnIndex += 1
            }
        }
        print(returnIndex, found)
        return (returnIndex, found)
    }
    
    func createPlanDaySlot(dayNum : Int) -> Void {
        let daySlot = NewTasks(context: container.viewContext)
        daySlot.id = UUID()
        daySlot.dayNum = Int16(dayNum)
        daySlot.taskArray = ""
        dailyPlans.append(daySlot)
        print(dailyPlans)
        save()
    }
    
    func createProfile(name : String, salary : Int) -> Void {
        let addedProfile = UserProfile(context: container.viewContext)
        addedProfile.id = UUID()
        addedProfile.penalty = Int16(0)
        addedProfile.name = name
        addedProfile.earnedPerDay = Int16(salary)
        userProfile.append(addedProfile)
        print(userProfile)
        save()
    }
    
    func addWork(number : Int) -> Void {
        let addableDay = MarkedDays(context: container.viewContext)
        addableDay.id = UUID()
        addableDay.workDay = Int16(number)
        workDays.append(addableDay)
        print(workDays)
        save()
    }
    
    func removeWork(number : Int) -> Void {
        let answer = finder(number: number)
        if answer.1 {
            let removableObject = workDays[answer.0]
            workDays.remove(at: answer.0)
            container.viewContext.delete(removableObject)
            save()
        }
    }
    
    func finder(number : Int) -> (Int, Bool) { // For finding the numbers and return decision.
        var found : Bool = false
        var returnIndex : Int = 0
        for search in workDays {
            if number == search.workDay {
                found = true
                print((returnIndex, found))
                return (returnIndex, found)
            }
            else {
                returnIndex += 1
            }
        }
        print((returnIndex, found))
        return (returnIndex, found)
    }
    
    func removeBusyDays() -> Void {
        guard workDays.count > 0 else {return}
        for _ in 0...workDays.count - 1 {
            let removableObject = workDays[0]
            container.viewContext.delete(removableObject)
            workDays.remove(at: 0)
        }
        save()
    }
    
    func changeSalary(new : Int) -> Void {
        guard userProfile.count > 0 else {return}
        userProfile[0].earnedPerDay = Int16(new)
        print("New salary is \(userProfile[0].earnedPerDay)")
        save()
    }
    
    func setPenalty(new : Int) -> Void {
        guard userProfile.count > 0 else { return }
        userProfile[0].penalty = Int16(new)
        print("Your penalty is : \(userProfile[0].penalty)")
        save()
    }
    
    func removeProfile() -> Void {
        let removedProfile = userProfile[0]
        userProfile.remove(at: 0)
        container.viewContext.delete(removedProfile)
        save()
    }
}
