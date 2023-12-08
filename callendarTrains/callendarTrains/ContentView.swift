//
//  ContentView.swift
//  callendarTrains
//
//  Created by Egor Ivanov on 27.04.2023.
//

import SwiftUI

// MARK: Content View

enum ScreenSets : String { // For screen changing.
    case mark
    case profile
    case planner
    case cashflow
    case archive
}

struct ContentView: View {
    @StateObject var dataModel = DataModel()
    @State var screen : String = ScreenSets.mark.rawValue
    let palette = Colors()
    var body: some View {
        let monthArray : [[Int]] = getDaysAmount()
        switch screen {
        case ScreenSets.mark.rawValue:
        ZStack {
            RadialGradient(colors: [palette.charcoal, palette.almond, palette.vanilla, palette.blue, palette.indigo, palette.purple], center: .topTrailing, startRadius: -400, endRadius: 800).ignoresSafeArea()
            VStack {
                Text("Mark mode")
                    .foregroundColor(.white)
                    .font(Font.custom("VampireWars", size: 35))
                    .padding()
                    .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5, y: 5))
                    .padding()
                    .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 5){
                    ForEach(monthArray.indices, id: \.self) { verticalic in
                        HStack(spacing: 5) {
                            ForEach(monthArray[verticalic].indices, id: \.self) { horyzontalic in
                                Button {
                                    switch isSaved(dayNum: monthArray[verticalic][horyzontalic]) {
                                    case true:
                                        dataModel.removeWork(number: monthArray[verticalic][horyzontalic])
                                    default:
                                        dataModel.addWork(number: monthArray[verticalic][horyzontalic])
                                    }
                                } label: {
                                    switch isSaved(dayNum: monthArray[verticalic][horyzontalic]) {
                                    case true:
                                        workCircle(horyzontalic: horyzontalic, verticalic: verticalic, monthArray: monthArray)
                                            .transition(.push(from: .top))
                                    default:
                                        freeCircle(horyzontalic: horyzontalic, verticalic: verticalic, monthArray: monthArray)
                                            .transition(.push(from: .top))
                                    }
                                }
                                .buttonStyle(.borderless)
                                
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(palette.vanilla))
                switch dataModel.userProfile.count {
                case 0:
                    NoProfileText(topPading: 40, bottomPadding: 30, workString: "No profile! Swipe up to begin.")
                        .transition(.push(from: .bottom))
                    Rectangle()
                        .opacity(0)
                    
                default:
                    Text("Info")
                        .foregroundColor(.white)
                        .font(Font.custom("VampireWars", size: 35))
                        .padding()
                        .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5, y: 5))
                        .padding()
                    ScrollView(.vertical, showsIndicators: false) {
                        NewViewStats(text: "Total working days : ", amount: dataModel.workDays.count)
                        NewViewStats(text: "Total free days : ", amount: totalDays() - dataModel.workDays.count)
                        NewViewStats(text: "Your penalty : ", amount: displayPenalty())
                        NewViewStats(text: "Your total income : ", amount: salaryWithPenalty())
                        NewViewStats(text: "Earned per day : ", amount: Int(dataModel.userProfile[0].earnedPerDay))
                        HStack {
                            RemoveBusyDays()
                                .environmentObject(dataModel)
                            RemoveProfile()
                                .environmentObject(dataModel)
                            ChangeSalary()
                                .environmentObject(dataModel)
                            ChangePenalty()
                                .environmentObject(dataModel)
                            
                        }.padding()
                    }
                    .padding()
                }
            }
        }.gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded({ direction in
            let horyzontalAmount = direction.translation.width
            let verticalAmount = direction.translation.height
            if abs(horyzontalAmount) > abs(verticalAmount) {
                if horyzontalAmount < 0 {
                    // Left gesture
                    print("Left swipe")
                    withAnimation(Animation.easeInOut) {
                        screen = ScreenSets.planner.rawValue
                    }
                }
                else {
                    // Right gesture
                    print("Right gesture")
                }
            }
            else {
                if verticalAmount < 0 {
                    // Up Gesture
                    print("Up gesture")
                    if dataModel.userProfile.count == 0 { // If there is no profile - swipe actions is blocked.
                        withAnimation(Animation.easeInOut) {
                            screen = ScreenSets.profile.rawValue
                        }
                    }
                }
                else {
                    // Down gesture
                    print("Down gesture")
                }
            }
        })
        )
        case ScreenSets.profile.rawValue:
            ProfileSetUp(screen: $screen)
                .transition(.push(from: .top))
                .environmentObject(dataModel)
        case ScreenSets.planner.rawValue:
            PlannerMode(screen: $screen)
                .transition(.push(from: .trailing))
                .environmentObject(dataModel)
        case ScreenSets.cashflow.rawValue:
            CashFlow(screen: $screen)
                .transition(.push(from: .trailing))
                .environmentObject(dataModel)
        case ScreenSets.archive.rawValue:
            SpentsArchive(screen: $screen)
                .transition(.push(from: .top))
                .environmentObject(dataModel)
            
        default:
            ProgressView()
            
    }
    }
    
    func isSaved(dayNum : Int) -> Bool {
        for numbers in dataModel.workDays {
            if dayNum == numbers.workDay {
                return true
            }
        }
        return false
    }
    
    func getDaysAmount() -> [[Int]] {
        let date = Date()
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .month, for: date)
        let days = calendar.dateComponents([.day], from: range!.start, to: range!.end)
        let endCountDays = Int(days.day!)
        switch endCountDays {
        case 28:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28]]
        case 29:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29]]
        case 30:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29,30]]
        default:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29,30,31]]
        }
    }
    
    func totalDays() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .month, for: date)
        let days = calendar.dateComponents([.day], from: range!.start, to: range!.end)
        let endCountDays = Int(days.day!)
        switch endCountDays {
        case 28:
            return 28
        case 29:
            return 29
        case 30:
            return 30
        default:
            return 31
        }
    }
    
    func calculateSalary() -> Int {
        return Int(dataModel.userProfile[0].earnedPerDay) * dataModel.workDays.count
    }
    
    func salaryWithPenalty() -> Int {
        return Int(dataModel.userProfile[0].earnedPerDay) * dataModel.workDays.count - Int(dataModel.userProfile[0].penalty)
    }
    
    func displayPenalty() -> Int {
        return Int(dataModel.userProfile[0].penalty)
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: Profile Set Screen

struct ProfileSetUp : View {
    @EnvironmentObject var dataModel : DataModel
    @State var showWarning : Bool = false
    @State var showNumber : Bool = false
    @State var name : String = "Your name"
    @State var earnedPerDay : String = "Your salary"
    @Binding var screen : String
    let palette = Colors()
    var body: some View {
        ZStack {
            RadialGradient(colors: [palette.almond, palette.vanilla, palette.blue, palette.indigo, palette.purple], center: .topLeading, startRadius: 50, endRadius: 850)
                .ignoresSafeArea()
            VStack {
                Text("Profile screen")
                    .foregroundColor(.white)
                    .font(Font.custom("VampireWars", size: 35))
                    .padding()
                    .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5, y: 5))
                    .padding()
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 180)
                        .padding()
                        .foregroundColor(palette.vanilla)
                        .shadow(color: palette.vanilla, radius: 10)
                    VStack {
                        ProfileTextField(information: $name)
                        ProfileTextField(information: $earnedPerDay)
                    }
                }
                .padding()
                .padding(.top, 65)
                
                NoProfileText(topPading: 0, bottomPadding: 150, workString: "Double tap on screen to create profile.")
                Rectangle().opacity(0)
                ArrowBottom()
                
            }
            if showWarning {
                WarningShell(warningString: "Please fill all required fields!")
                    .transition(.slide)
            }
            if showNumber {
                WarningShell(warningString: "Please enter integer number!")
            }
        }
        .onTapGesture(count: 2, perform: {
            switch checkFields() {
            case false:
                withAnimation(Animation.easeInOut) {
                    showWarning.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    withAnimation(Animation.easeInOut) {
                        showWarning.toggle()
                    }
                }
            default:
                dataModel.createProfile(name: name, salary: Int(earnedPerDay) ?? 0)
                withAnimation(.easeInOut) {
                    screen = ScreenSets.mark.rawValue
                }
            }
        })
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded({ direction in
            let horyzontalAmount = direction.translation.width
            let verticalAmount = direction.translation.height
            if abs(horyzontalAmount) > abs(verticalAmount) {
                if horyzontalAmount < 0 {
                    // Left gesture
                    print("Left swipe")
                }
                else {
                    // Right gesture
                    print("Right gesture")
                }
            }
            else {
                if verticalAmount < 0 {
                    // Up Gesture
                    print("Up gesture")
                    withAnimation(Animation.easeInOut) {
                        screen = ScreenSets.mark.rawValue
                    }
                }
                else {
                    // Down gesture
                    print("Down gesture")
                }
            }
        })
        )
    }
    func checkFields() -> Bool {
        if name == "Your name" || name == "" {
            return false
        }
        else if earnedPerDay == "Your salary" || earnedPerDay == "" {
            return false
        }
        return true
    }
}


// MARK: Planner Mode Screen

struct PlannerMode : View {
    @State var dayTask : String = "Enter your task"
    @State var selectedDay : Int = 0
    @State var displayAddons : Bool = true
    @EnvironmentObject var dataModel : DataModel
    @Binding var screen : String
    let palette = Colors()
    var body: some View {
        let monthArray : [[Int]] = getDaysAmount()
        ZStack {
            RadialGradient(colors: [palette.charcoal, palette.almond, palette.vanilla, palette.blue, palette.indigo, palette.purple], center: .bottomLeading, startRadius: -500, endRadius: 800).ignoresSafeArea()
            VStack {
                HighTitle(paddingBottom: 0, text: "Planner Mode")
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(monthArray.indices, id: \.self) { verticalic in
                        HStack(spacing: 5) {
                            ForEach(monthArray[verticalic].indices, id: \.self) { horyzontalic in
                                Button {
                                    guard selectedDay != monthArray[verticalic][horyzontalic] else {
                                        withAnimation(.easeInOut) {
                                            selectedDay = 0
                                        }
                                        return
                                    }
                                    withAnimation(.easeInOut) {
                                        selectedDay = monthArray[verticalic][horyzontalic]
                                    }
                                } label: {
                                    switch monthArray[verticalic][horyzontalic] {
                                    case selectedDay:
                                        SelectedCircle(horyzontalic: horyzontalic, verticalic: verticalic, monthArray: monthArray)
                                            .transition(.push(from: .top))
                                    default:
                                        freeCircle(horyzontalic: horyzontalic, verticalic: verticalic, monthArray: monthArray)
                                            .transition(.push(from: .top))
                                    }
                                }
                                .buttonStyle(.borderless)
                                
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(palette.vanilla).shadow(color: palette.charcoal, radius: 15))
                switch selectedDay {
                case 0:
                    NoProfileText(topPading: 50, bottomPadding: 50, workString: "Select a day to start planning it.")
                        .transition(.push(from: .bottom))
                    Rectangle()
                        .opacity(0)
                default:
                    switch isSaved(dayNum: selectedDay) {
                    case true:
                        if displayAddons == true {
                            ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 300, height: 120)
                                .foregroundColor(palette.blue)
                            VStack {
                                ProfileTextField(information: $dayTask)
                                Text("Double tap here to add.")
                                    .foregroundColor(.white)
                                    .font(Font.custom("VampireWars", size: 22))
                                    .underline()
                            }
                        }
                            .padding()
                            .transition(.push(from: .top))
                            .onTapGesture(count: 2) {
                                withAnimation(.easeInOut) {
                                    dataModel.addTasktoDay(dayNum: selectedDay, task: dayTask)
                                }
                            dayTask = "Enter your task"
                        }
                    }
                        if dataModel.dailyPlans[dataModel.findDay(number: selectedDay).0].taskArray != "" {
                        List {
                            let workArray = unwrapper(array: dataModel.dailyPlans[dataModel.findDay(number: selectedDay).0].taskArray?.components(separatedBy: "|"))
                            ForEach(workArray.indices, id: \.self) { object in
                                HStack {
                                    Text(workArray[object])
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: 280, alignment: .leading)
                                        .font(Font.custom("SketchGothicSchool", size: 30))
                                        .foregroundColor(.black)
                                    Button {
                                        withAnimation(.easeInOut) {
                                            dataModel.removeSelectedTask(array: workArray, indexRemove: object, selectedDay: selectedDay)
                                        }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundColor(.black)
                                            .font(.system(size: 25))
                                    }
                                }
                            }
                            .transition(.slide)
                            .listRowBackground(palette.vanilla)
                        }
                        .scrollContentBackground(.hidden)
                        .transition(.slide)
                    }
                    else {
                        NoProfileText(topPading: 0, bottomPadding: 0, workString: "No plans.")
                            .transition(.push(from: .bottom))
                        Rectangle().opacity(0)
                        }
                    case false:
                        NoProfileText(topPading: 0, bottomPadding: 0, workString: "Double click here.")
                            .transition(.push(from: .bottom))
                            .onTapGesture(count: 2) {
                                dataModel.createPlanDaySlot(dayNum: selectedDay)
                            }
                        Rectangle()
                            .opacity(0)
                    }
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded({ direction in
            let horyzontalAmount = direction.translation.width
            let verticalAmount = direction.translation.height
            if abs(horyzontalAmount) > abs(verticalAmount) {
                if horyzontalAmount < 0 {
                    // Left gesture
                    print("Left swipe")
                    withAnimation(Animation.easeInOut) {
                        screen = ScreenSets.cashflow.rawValue
                    }
                }
                else {
                    // Right gesture
                    print("Right gesture")
                    withAnimation(.easeInOut) {
                        screen = ScreenSets.mark.rawValue
                    }
                }
            }
            else {
                if verticalAmount < 0 {
                    // Up Gesture
                    print("Up gesture")
                    withAnimation(.easeInOut) {
                        displayAddons.toggle()
                    }
                    
                }
                else {
                    // Down gesture
                    print("Down gesture")
                }
            }
        })
        )
        .onAppear {
            selectedDay = dateCorrection()
        }
    }
    func dateCorrection() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.day, from: date)
    }
    
    func getDaysAmount() -> [[Int]] {
        let date = Date()
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .month, for: date)
        let days = calendar.dateComponents([.day], from: range!.start, to: range!.end)
        let endCountDays = Int(days.day!)
        switch endCountDays {
        case 28:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28]]
        case 29:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29]]
        case 30:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29,30]]
        default:
            return [[1,2,3,4,5,6,7], [8,9,10,11,12,13,14], [15,16,17,18,19,20,21], [22,23,24,25,26,27,28], [29,30,31]]
        }
    }
    
    func totalDays() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .month, for: date)
        let days = calendar.dateComponents([.day], from: range!.start, to: range!.end)
        let endCountDays = Int(days.day!)
        switch endCountDays {
        case 28:
            return 28
        case 29:
            return 29
        case 30:
            return 30
        default:
            return 31
        }
    }
    
    func isSaved(dayNum : Int) -> Bool {
        for numbers in dataModel.dailyPlans {
            if dayNum == numbers.dayNum {
                return true
            }
        }
        return false
    }
    
    func unwrapper(array : [String]?) -> [String] {
        if let safeOpened = array {
            return safeOpened
        }
        return ["Nothing"]
    }
}



// MARK: CashFlow screen

struct CashFlow : View {
    @State var information : String = "TextField"
    @Binding var screen : String
    @EnvironmentObject var dataModel : DataModel
    let palette = Colors()
    var body: some View {
        ZStack {
            LinearGradient(colors: [palette.charcoal, palette.purple, palette.indigo, palette.blue, palette.almond, palette.vanilla], startPoint: .bottom, endPoint: .top).ignoresSafeArea()
            VStack {
                HighTitle(paddingBottom: 0, text: "CashFlow mode")
                NoProfileText(topPading: 0, bottomPadding: 0, workString: "Enter your spents with a short description.")
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 300, height: 120)
                        .padding()
                        .foregroundColor(palette.vanilla)
                        .shadow(color: palette.vanilla, radius: 5)
                    VStack {
                        ProfileTextField(information: $information)
                        Text("Double tap here to submit.")
                            .foregroundColor(.black)
                            .font(Font.custom("VampireWars", size: 18))
                            .padding(2)
                    }
                }.onTapGesture(count: 2) {
                    prepareForWriting()
                }
                let readyArray = sortDataEnum(dayNumber: returnCurrentDay(), monthNumber: returnCurrentMonth())
                switch readyArray.count {
                case 0:
                    NoProfileText(topPading: 0, bottomPadding: 0, workString: "No spents. Add something.")
                    Rectangle().opacity(0)
                default:
                    List {
                            Section(header: Text(createReadDate()).font(Font.custom("TRN", size: 30)).foregroundColor(.white)) {
                                HStack {
                                    Text("Daily expenses : \(getExpenses())")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(.white)
                                        .font(Font.custom("VampireWars", size: 20))
                                        .frame(width: 300, alignment: .leading)
                                    
                                }.listRowBackground(palette.blue)
                                ForEach(readyArray.indices, id: \.self) { element in
                                HStack {
                                    Text(readyArray[element].name!)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: 180, alignment: .leading)
                                        .font(Font.custom("SketchGothicSchool", size: 30))
                                        .foregroundColor(.black)
                                    Text("\(readyArray[element].costage)")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: 100, alignment: .center)
                                        .font(Font.custom("SketchGothicSchool", size: 30))
                                        .foregroundColor(.black)
                                    Button {
                                        withAnimation(.easeInOut) {
                                            dataModel.removeByIndexSpents(element: readyArray[element])
                                        }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundColor(.black)
                                            .font(.system(size: 25))
                                    }
                                }
                                }
                        }.listRowBackground(palette.vanilla)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }.gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded({ direction in
            let horyzontalAmount = direction.translation.width
            let verticalAmount = direction.translation.height
            if abs(horyzontalAmount) > abs(verticalAmount) {
                if horyzontalAmount < 0 {
                    // Left gesture
                    print("Left swipe")
                }
                else {
                    // Right gesture
                    print("Right gesture")
                    withAnimation(.easeInOut) {
                        screen = ScreenSets.planner.rawValue
                    }
                }
            }
            else {
                if verticalAmount < 0 {
                    // Up Gesture
                    print("Up gesture")
                    withAnimation(.easeInOut) {
                        screen = ScreenSets.archive.rawValue
                    }
                }
                else {
                    // Down gesture
                    print("Down gesture")
                }
            }
        })
        )

    }
    
    func sortDataEnum(dayNumber : Int, monthNumber : Int) -> [DailySpents] {
        var sortedArray : [DailySpents] = []
        for (_, element) in dataModel.dailySpents.enumerated() {
            if element.monthNumber == monthNumber && element.dayNumber == dayNumber {
                sortedArray.append(element)
            }
        }
        print(sortedArray)
        return sortedArray
    }
    
    func getExpenses() -> Int {
        var result : Int = 0
        for elements in sortDataEnum(dayNumber: returnCurrentDay(), monthNumber: returnCurrentMonth()) {
            result += Int(elements.costage)
        }
        return result
    }
    
    func prepareForWriting() -> Void {
        // fix for empty field block.
        let separatedParts = information.components(separatedBy: " ")
        print(separatedParts)
        var descriptionString = ""
        for (index, element) in separatedParts.enumerated() {
            if index != 0 {
                descriptionString += element
                descriptionString += " "
            }
        }
        print(descriptionString)
        information = "TextField"
        withAnimation(.easeInOut(duration: 0.5)) {
            dataModel.addSpents(nameOfSpent: descriptionString, costage: Int(separatedParts[0]) ?? 0)
        }
    }
    func returnCurrentDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.day, from: date)
    }
    
    func returnCurrentMonth() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
    
    func createReadDate() -> String {
        var returnString = ""
        returnString += String(returnCurrentDay())
        returnString += ","
        returnString += " "
        switch returnCurrentMonth() {
        case 1:
            returnString += "January"
        case 2:
            returnString += "February"
        case 3:
            returnString += "March"
        case 4:
            returnString += "April"
        case 5:
            returnString += "May"
        case 6:
            returnString += "June"
        case 7:
            returnString += "July"
        case 8:
            returnString += "August"
        case 9:
            returnString += "September"
        case 10:
            returnString += "October"
        case 11:
            returnString += "November"
        case 12:
            returnString += "December"
        default:
            returnString += "Nothing"
        
        }
        return returnString
    }
}

// MARK: Arhive for spents screen.

struct SpentsArchive : View {
    @Binding var screen : String
    let palette = Colors()
    @EnvironmentObject var dataModel : DataModel
    let paramsArray : [String] = ["Total sum spent per day :", "Total expenses per day :", "Your biggest expense :"]
    @State var archiveDisplay : [ArchiveCell] = [] // Make it blank when I'm ready.
    var body: some View {
        ZStack {
            LinearGradient(colors: [palette.purple, palette.indigo, palette.blue], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            VStack(spacing: 0) {
                HighTitle(paddingBottom: 0, text: "Archieved")
                ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    switch archiveDisplay.count {
                    case 0:
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                        }
                    default:
                        ForEach(archiveDisplay.indices, id: \.self) { indexRow in
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 300, height: 300)
                                    .padding()
                                    .foregroundColor(palette.vanilla)
                                List {
                                    Section(header: Text(createReadDate(day: archiveDisplay[indexRow].dayNum, month: archiveDisplay[indexRow].monthNum, year: archiveDisplay[indexRow].year))
                                        .font(Font.custom("VampireWars", size: 20))
                                        .foregroundColor(.black)
                                            
                                    ) {
                                        ForEach(paramsArray.indices, id: \.self) { index in
                                            switch index {
                                            case 0:
                                                ArchievedListCell(description: paramsArray[index], number: archiveDisplay[indexRow].totalBuyAmount)
                                            case 1:
                                                ArchievedListCell(description: paramsArray[index], number: archiveDisplay[indexRow].totalExpenses)
                                            default:
                                                ArchievedListCell(description: paramsArray[index], number: archiveDisplay[indexRow].biggestSpent) // biggest spent
                                            }
                                        }
                                        .listRowBackground(palette.vanilla)
                                    }
                                }
                                .scrollContentBackground(.hidden)
                                .frame(width: 300, height: 280)
                                .padding()
                            }
                            .id(archiveDisplay[indexRow].id)
                            .transition(.push(from: .bottom))
                        }
                    }
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(archiveDisplay.last?.id)
                        }
                    }
                }
            }
                ZStack {
                    Rectangle()
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(.thinMaterial)
                    Text("Double tap to return.")
                        .foregroundColor(.white)
                        .font(Font.custom("VampireWars", size: 30))
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut) {
                                screen = ScreenSets.cashflow.rawValue
                            }
                        }
                }
            }
        }
        .onAppear {
            getDataTuple(tupleArray: findAllVariables())
        }
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded({ direction in
            let horyzontalAmount = direction.translation.width
            let verticalAmount = direction.translation.height
            if abs(horyzontalAmount) > abs(verticalAmount) {
                if horyzontalAmount < 0 {
                    // Left gesture
                    print("Left swipe")
                }
                else {
                    // Right gesture
                    print("Right gesture")
                }
            }
            else {
                if verticalAmount < 0 {
                    // Up Gesture
                    print("Up gesture")
                }
                else {
                    // Down gesture
                    print("Down gesture")
                }
            }
        })
        )
    }
    
    func findAllVariables() -> [(Int16, Int16, Int16)] {
        var found : Bool = false
        var tupleVars : [(Int16, Int16, Int16)] = []
        for elements in dataModel.dailySpents {
            let sample = (elements.dayNumber, elements.monthNumber, elements.year)
            for subcheck in tupleVars {
                if subcheck == sample {
                    found = true
                }
            }
            if !found {
                tupleVars.append(sample)
            }
            found = false
        }
        print(tupleVars)
        return tupleVars
    }
    
    func getDataTuple(tupleArray : [(Int16, Int16, Int16)]) -> Void {
        var elementsToAdd : [DailySpents] = []
        for build in tupleArray {
            for (_, check) in dataModel.dailySpents.enumerated() {
                if build.0 == check.dayNumber && build.1 == check.monthNumber && build.2 == check.year {
                    elementsToAdd.append(check)
                }
            }
            guard elementsToAdd.count > 0 else { return }
            let cell = ArchiveCell(dayNum: Int(elementsToAdd[0].dayNumber), monthNum: Int(elementsToAdd[0].monthNumber), year: Int(elementsToAdd[0].year), totalExpenses: elementsToAdd.count, biggestSpent: biggestSpentCalculator(array: elementsToAdd), totalBuyAmount: totalBuyAmountCalculator(array: elementsToAdd))
            withAnimation(.easeInOut(duration: 0.7)) { // Animation for notes appear.
                archiveDisplay.append(cell)
            }
            elementsToAdd = []
        }
        print(archiveDisplay)
    }
    
    func biggestSpentCalculator(array : [DailySpents]) -> Int {
        var returnValue : Int = 0
        for elements in array {
            if elements.costage > returnValue {
                returnValue = Int(elements.costage)
            }
        }
        return returnValue
    }
    
    func totalBuyAmountCalculator(array : [DailySpents]) -> Int {
        var returnSum : Int = 0
        for elements in array {
            returnSum += Int(elements.costage)
        }
        return returnSum
    }
    
    func createReadDate(day : Int, month : Int, year : Int) -> String {
        var returnString = ""
        returnString += String(day)
        returnString += ","
        returnString += " "
        switch month {
        case 1:
            returnString += "January"
        case 2:
            returnString += "February"
        case 3:
            returnString += "March"
        case 4:
            returnString += "April"
        case 5:
            returnString += "May"
        case 6:
            returnString += "June"
        case 7:
            returnString += "July"
        case 8:
            returnString += "August"
        case 9:
            returnString += "September"
        case 10:
            returnString += "October"
        case 11:
            returnString += "November"
        case 12:
            returnString += "December"
        default:
            returnString += "Nothing"
        
        }
        return returnString
    }
}



// MARK: Addons for buildings

struct HighTitle : View {
    let paddingBottom : CGFloat
    let palette = Colors()
    let text : String
    var body: some View {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.45)
            .foregroundColor(.white)
            .font(Font.custom("VampireWars", size: 35))
            .padding()
            .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5, y: 5))
            .padding()
            .padding(.bottom, paddingBottom)
    }
}

struct ProfileTextField : View { // TextField for profile information
    @Binding var information : String
    var body: some View {
        TextField("", text: $information)
            .autocorrectionDisabled()
            .minimumScaleFactor(0.5)
            .foregroundColor(.white)
            .font(Font.custom("TRN", size: 30))
            .frame(width: 250, height: 15, alignment: .center)
            .multilineTextAlignment(.center)
            .padding()
            .padding(.top, 6)
            .background(Capsule().fill(.black))
            .padding(4)
            .onTapGesture {
                withAnimation(.easeInOut) {
                    information = ""
                }
            }
    }
}


struct workCircle : View { // Circle for workDay
    let palette = Colors()
    let horyzontalic : Int
    let verticalic : Int
    let monthArray : [[Int]]
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40)
                .foregroundColor(.white)
            Text("\(monthArray[verticalic][horyzontalic])")
                .font(Font.custom("SketchGothicSchool", size: 30))
                .foregroundColor(.black)
                .padding(.bottom, 2)
            Image(systemName: "xmark")
                .font(.system(size: 30))
                .foregroundColor(palette.blue)
        }
    }
}

struct SelectedCircle : View { // Circle for workDay
    let palette = Colors()
    let horyzontalic : Int
    let verticalic : Int
    let monthArray : [[Int]]
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40)
                .foregroundColor(.white)
            Text("\(monthArray[verticalic][horyzontalic])")
                .font(Font.custom("SketchGothicSchool", size: 30))
                .foregroundColor(.black)
                .padding(.bottom, 2)
        }
    }
}

struct freeCircle : View { // Circle for freeDay
    let palette = Colors()
    let horyzontalic : Int
    let verticalic : Int
    let monthArray : [[Int]]
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 40)
                .foregroundColor(palette.vanilla)
                .shadow(color: palette.vanilla, radius: 3)
                .background(Rectangle().stroke(.black, lineWidth: 3))
            Text("\(monthArray[verticalic][horyzontalic])")
                .font(Font.custom("Electrolize-Regular", size: 25))
                .foregroundColor(.black)
                .padding(.bottom, 2)
        }
    }
}





struct NoProfileText : View { // For annotations in the bottom.
    let topPading : CGFloat
    let bottomPadding : CGFloat
    let workString : String
    var body: some View {
        let palette = Colors()
        Text(workString)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding()
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 20).fill(palette.blue))
            .font(Font.custom("VampireWars", size: 25))
            .padding()
            .padding(.top, topPading)
            .padding(.bottom, bottomPadding)
    }
}

struct ArrowBottom : View {
    var body: some View {
        Image(systemName: "arrow.up")
            .foregroundColor(.white)
            .font(.system(size: 50))
            .shadow(color: .white, radius: 2)
    }
}

struct WarningShell : View {
    let warningString : String
    var body: some View {
        let palette = Colors()
        Text(warningString)
            .foregroundColor(Color.black)
            .font(Font.custom("TRN", size: 25))
            .shadow(color: .black, radius: 1)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(palette.red).shadow(color: palette.red, radius: 3))
    }
}

struct TextInfoMark : View {
    let text : String
    let amount : Int
    let palette = Colors()
    var body: some View {
        Text("\(text) \(amount)")
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .padding()
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 20).fill(palette.vanilla).shadow(color: palette.vanilla, radius: 5, y: 5))
            .font(Font.custom("VampireWars", size: 25))
            .padding()
    }
}

struct NewViewStats : View {
    let text : String
    let amount : Int
    let palette = Colors()
    var body: some View {
        Text("\(text) \(amount)")
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .padding()
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 20).fill(palette.vanilla))
            .font(Font.custom("VampireWars", size: 25))
            .padding(5)
    }
}

struct NewViewCopy : View {
    let text : String
    let palette = Colors()
    var body: some View {
        Text("\(text)")
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .padding()
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 20).fill(palette.vanilla))
            .font(Font.custom("VampireWars", size: 25))
            .padding(5)
    }
}

struct RemoveBusyDays : View {
    @State var showAlert : Bool = false
    @EnvironmentObject var dataModel : DataModel
    let palette = Colors()
    var body: some View {
            Button {
                showAlert.toggle()
            } label: {
                Image(systemName: "tablecells")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5))
                    .padding(5)
            }.alert("Warning!\nAre you sure you want to remove all marks from organizer?", isPresented: $showAlert) {
                Button("OK", role: .destructive) {dataModel.removeBusyDays()}
                Button("Cancel", role: .cancel) {}
            }
        }
}

struct RemoveProfile : View {
    @State var showAlert : Bool = false
    @EnvironmentObject var dataModel : DataModel
    let palette = Colors()
    var body: some View {
            Button {
                showAlert.toggle() // Change to removeprofile function
            } label: {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5))
                        .padding(5)
            }.alert("Warning!\nAre you sure you wish to remove your profile?", isPresented: $showAlert) {
                Button("OK", role: .destructive) {
                    withAnimation(Animation.easeInOut) {
                        dataModel.removeProfile()}
                }
                Button("Cancel", role: .cancel) {}
            }
        }
}

struct ChangeSalary : View {
    @State var showAlert : Bool = false
    @State var newSalary : String = ""
    @EnvironmentObject var dataModel : DataModel
    let palette = Colors()
    var body: some View {
            Button {
                showAlert.toggle()
            } label: {
                Image(systemName: "dollarsign.arrow.circlepath")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5))
                        .padding(5)
            }.alert("Warning!\nAre you sure you want to change your salary per day?", isPresented: $showAlert) {
                TextField("Enter your new salary", text: $newSalary)
                Button("Commit changes.") {
                    dataModel.changeSalary(new: Int(newSalary) ?? 0)
                }
                Button("Cancel", role: .cancel) {}
            }
        }
}

struct ArchievedListCell : View {
    let description : String
    let number : Int
    var body: some View {
        Text("\(description) \(number)")
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundColor(.black)
            .font(Font.custom("SketchGothicSchool", size: 25))
            .listRowSeparator(.hidden)
    }
}

struct ChangePenalty : View {
    @State var showAlert : Bool = false
    @State var newSalary : String = ""
    @EnvironmentObject var dataModel : DataModel
    let palette = Colors()
    var body: some View {
            Button {
                showAlert.toggle()
            } label: {
                Image(systemName: "fireplace")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(palette.blue).shadow(color: palette.blue, radius: 5))
                        .padding(5)
            }.alert("Warning!\nAre you sure you want to set a penalty to your salary?", isPresented: $showAlert) {
                TextField("Enter an amount of penalty", text: $newSalary)
                Button("Commit changes.") {
                    dataModel.setPenalty(new: Int(newSalary) ?? 0)
                }
                Button("Cancel", role: .cancel) {}
            }
        }
}

// MARK: Structs for displaying information.

struct ArchiveCell : Identifiable {
    let id = UUID()
    let dayNum : Int
    let monthNum : Int
    let year : Int
    var totalExpenses : Int
    var biggestSpent : Int
    var totalBuyAmount : Int
}
