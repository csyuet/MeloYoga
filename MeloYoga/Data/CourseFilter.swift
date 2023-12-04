//
//  CourseFilter.swift
//  MeloYoga
//


import Foundation

enum TimeSortingOptions: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case none = "None"
    case asc = "Earliest to Latest"
    case desc = "Latest to Earliest"
}

enum NameSortingOptions: String, CaseIterable, Identifiable {
    var id: NameSortingOptions { self }
    case none = "None"
    case asc = "Ascending order"
    case desc = "Descending order"
}

enum NumSortingOptions: String, CaseIterable, Identifiable {
    var id: NumSortingOptions { self }
    case none = "None"
    case asc = "Lowest to Highest"
    case desc = "Highest to Lowest"
}

enum TypeFilterOptions: String, CaseIterable{
    case all = "All"
    case ari = "Aerial"
    case dan = "Dance"
    case yog = "Yoga"

    static let allValues = [all.rawValue, ari.rawValue, dan.rawValue, yog.rawValue]
    static let allSelected = [ari.rawValue, dan.rawValue, yog.rawValue]
}

enum CoachFilterOptions: String, CaseIterable{
    case all = "All"
    case k = "Katia Kwok"
    case r = "Rain Mo"
    case v = "Valetta Cheung"

    static let allValues = [all.rawValue, k.rawValue, r.rawValue, v.rawValue]
    static let allSelected = [k.rawValue, r.rawValue, v.rawValue]
}

struct Setting: Identifiable{
    var type: String
    var value: NSSortDescriptor
    var id: String{ self.type }
}

class CourseFilter: ObservableObject{
    //for CourseOfWeek entity
    @Published var customSort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: true)]
    @Published var timeOption: TimeSortingOptions = .asc
    @Published var tnameOption: NameSortingOptions = .none
    @Published var cnameOption: NameSortingOptions = .none
    @Published var numOption: NumSortingOptions = .none
    
    @Published var customPredicate: NSCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [])
    @Published var sortSettings: [Setting] = []
    @Published var timeFrom: Date = Date()
    @Published var timeTo: Date = Date()
    @Published var typeSelected: [String] = ["All"]
    @Published var coachSelected: [String] = ["All"]
    @Published var maxCred: Int = 10
    @Published var minCred: Int = 0
    
    var timeSort: NSSortDescriptor = NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: true)
    var typeSort: NSSortDescriptor = NSSortDescriptor(keyPath: \CourseOfWeek.type, ascending: true)
    var coachSort: NSSortDescriptor = NSSortDescriptor(keyPath: \CourseOfWeek.coach, ascending: true)
    var credSort: NSSortDescriptor = NSSortDescriptor(keyPath: \CourseOfWeek.cred, ascending: true)
    
    private var customPredicates: [NSPredicate] = []
    var timeFilter: NSPredicate = NSPredicate(format: "startTime >= %@ AND startTime <= %@", "0000" as NSString, "2359" as NSString)
    var typeFilter: NSPredicate = NSPredicate(format:"type IN %@", TypeFilterOptions.allSelected)
    var coachFilter: NSPredicate = NSPredicate(format:"coach IN %@", CoachFilterOptions.allSelected)
    var credFilter: NSPredicate = NSPredicate(format: "cred BETWEEN { %i, %i }", 0, 10)
    
    var weekdayFilter: NSPredicate = NSPredicate(format: "weekday = %@", "Monday" as NSString)
    @Published var onDate: NSPredicate = NSPredicate(format: "weekday = %@", "Monday" as NSString)
    
    //for Course entity
    @Published var onday: NSPredicate = NSPredicate(format: "startTime >= %@", Date() as NSDate)
    @Published var upcoming: NSPredicate = NSPredicate(format: "startTime >= %@", Date() as NSDate)
    @Published var previous: NSPredicate = NSPredicate(format: "startTime < %@", Date() as NSDate)

    init(){
        exactDate(date: Date())
        setDefaultTime(date: Date())
        filterUpdate()
    }
    
    func defaultSorting(){
        timeOption = .asc
        tnameOption = .none
        cnameOption = .none
        numOption = .none
    }
    
    func defaultFilter(){
        let startDate = Calendar.current.startOfDay(for: Date())
        timeFrom = startDate
        var components = DateComponents()
        components.day = 1
        components.second = -1
        timeTo = Calendar.current.date(byAdding: components, to: startDate)!
        
        typeSelected = ["All"]
        coachSelected = ["All"]
        maxCred = 10
        minCred = 0
    }
    
    func setDefaultTime(date: Date){
        let startDate = Calendar.current.startOfDay(for: date)
        timeFrom = startDate
        var components = DateComponents()
        components.day = 1
        components.second = -1
        timeTo = Calendar.current.date(byAdding: components, to: startDate)!
        
        weekdayFilter = NSPredicate(format: "weekday = %@", toWeekDay(date: date) as NSString)
        
        if Calendar.current.isDateInToday(date){
            timeFilter = NSPredicate(format: "startTime BETWEEN { %@, %@ }", toHrMin(date: Date()) as NSString, toHrMin(date: timeTo) as NSString)
        } else {
            timeFilter = NSPredicate(format: "startTime BETWEEN { %@, %@ }", toHrMin(date: startDate) as NSString, toHrMin(date: timeTo) as NSString)
        }
        onDate = NSCompoundPredicate(type: .and, subpredicates: [weekdayFilter, timeFilter])
    }
    
    func exactDate(date: Date){
        let startDate = Calendar.current.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = Calendar.current.date(byAdding: components, to: startDate)!
        onday = NSPredicate(format: "startTime >= %@ AND endTime <= %@", startDate as NSDate, endDate as NSDate)
        
        weekdayFilter = NSPredicate(format: "weekday = %@", toWeekDay(date: date) as NSString)
        if Calendar.current.isDateInToday(date){
            let timeF = toHrMin(date: timeFrom)
            let time = toHrMin(date: Date())
            timeFilter = NSPredicate(format: "startTime BETWEEN { %@, %@ }", timeF > time ? timeF : time as NSString, toHrMin(date: timeTo) as NSString)
        } else {
            timeFilter = NSPredicate(format: "startTime BETWEEN { %@, %@ }", toHrMin(date: timeFrom) as NSString, toHrMin(date: timeTo) as NSString)
        }
        onDate = NSCompoundPredicate(type: .and, subpredicates: [weekdayFilter, timeFilter])
    }
    
    func sortUpdate(){
        sortSettingsUpdate()
        customSort.removeAll()
        if timeOption != .none{
            timeSort = NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: timeOption == .asc)
            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: timeOption == .asc))
            
        }
        if tnameOption != .none{
            typeSort = NSSortDescriptor(keyPath: \CourseOfWeek.type, ascending: tnameOption == .asc)
            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.type, ascending: tnameOption == .asc))
        }
        if cnameOption != .none{
            coachSort = NSSortDescriptor(keyPath: \CourseOfWeek.coach, ascending: cnameOption == .asc)
            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.coach, ascending: cnameOption == .asc))
        }
        if numOption != .none{
            credSort = NSSortDescriptor(keyPath: \CourseOfWeek.cred, ascending: numOption == .asc)
            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.cred, ascending: numOption == .asc))
        }
//        sortSettingsUpdate()
    }
    
    func sortSettingsUpdate(){
        if timeOption != .none{
            timeSort = NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: timeOption == .asc)
//            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.startTime, ascending: timeOption == .asc))
//            if sortSettings.contains(where: {$0.type == "Time" && $0.value.ascending != (timeOption == .asc)}){
            if !sortSettings.contains(where: {$0.type == "Time"}){
                sortSettings.append(Setting(type: "Time", value: timeSort))
            }
        } else {
            sortSettings.removeAll(where: {$0.type == "Time"})
        }
        if tnameOption != .none{
            typeSort = NSSortDescriptor(keyPath: \CourseOfWeek.type, ascending: tnameOption == .asc)
//            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.type, ascending: tnameOption == .asc))
            if !sortSettings.contains(where: {$0.type == "Type Name"}){
                sortSettings.append(Setting(type: "Type Name", value: typeSort))
            }
        } else {
            sortSettings.removeAll(where: {$0.type == "Type Name"})
        }
        if cnameOption != .none{
            coachSort = NSSortDescriptor(keyPath: \CourseOfWeek.coach, ascending: cnameOption == .asc)
//            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.coach, ascending: cnameOption == .asc))
            if !sortSettings.contains(where: {$0.type == "Coach Name"}){
                sortSettings.append(Setting(type: "Coach Name", value: coachSort))
            }
        } else {
            sortSettings.removeAll(where: {$0.type == "Coach Name"})
        }
        if numOption != .none{
            credSort = NSSortDescriptor(keyPath: \CourseOfWeek.cred, ascending: numOption == .asc)
//            customSort.append(NSSortDescriptor(keyPath: \CourseOfWeek.cred, ascending: numOption == .asc))
            if !sortSettings.contains(where: {$0.type == "Credits"}){
                sortSettings.append(Setting(type: "Credits", value: credSort))
            }
        } else {
            sortSettings.removeAll(where: {$0.type == "Credits"})
        }
        
    }
    
    func filterUpdate(selectedDate: Date, ft: Date, tt: Date, st: [String], sc: [String], max: Int, min: Int){
        timeFrom = ft
        timeTo = tt
        typeSelected = st
        coachSelected = sc
        maxCred = max
        minCred = min

        exactDate(date: selectedDate)

        if typeSelected.contains("All") {
            typeFilter = NSPredicate(format:"type IN %@", TypeFilterOptions.allSelected)
        } else {
            typeFilter = NSPredicate(format:"type IN %@", typeSelected)
        }
        if coachSelected.contains("All"){
            coachFilter = NSPredicate(format:"coach IN %@", CoachFilterOptions.allSelected)
        } else {
            coachFilter = NSPredicate(format:"coach IN %@", coachSelected)
        }
        
        credFilter = NSPredicate(format: "cred BETWEEN { %i, %i }", minCred, maxCred)
    }
    
    func filterUpdate(){
        customPredicate = NSCompoundPredicate(type: .and, subpredicates: [onDate, typeFilter, coachFilter, credFilter])
    }
    
    func toWeekDay(date: Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: date)
        return weekDay
    }
    
    func toHrMin(date: Date) -> String{
        let day = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(day.hour!) + String(day.minute!)
    }
    
    func upcomingCourses(user: User) -> [Course]{
        return user.booked!.filtered(using: upcoming).sortedArray(using: [NSSortDescriptor(keyPath: \Course.startTime, ascending: true)]) as! [Course]
    }
    
    func previousCourses(user: User) -> [Course]{
        return user.booked!.filtered(using: previous).sortedArray(using: [NSSortDescriptor(keyPath: \Course.startTime, ascending: true)]) as! [Course]
    }
    
}
