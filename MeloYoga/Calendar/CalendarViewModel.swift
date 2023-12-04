//
//  CalendarDataModel.swift
//  MeloYoga
//

import Foundation

class CalendarViewModel: ObservableObject{
    @Published var prevWeek: [Date] = []
    @Published var curWeek: [Date] = []
    @Published var nextWeek: [Date] = []
    @Published var selectedDate: Date = Date()
    
    init(){
        fetchWeeks(date: Date())
    }
    
    func fetchWeeks(date: Date){
        prevWeek.removeAll()
        curWeek.removeAll()
        nextWeek.removeAll()
        let week = Calendar.current.dateInterval(of: .weekOfMonth, for: date)

        guard let firstWeekDay = week?.start else {return }
        
        (0...6).forEach{ day in
            if let weekday = Calendar.current.date(byAdding: .day, value: -7 + day, to: firstWeekDay) {
                prevWeek.append(weekday)
            }
            if let weekday = Calendar.current.date(byAdding: .day, value: day, to: firstWeekDay) {
                curWeek.append(weekday)

            }
            if let weekday = Calendar.current.date(byAdding: .day, value: 7 + day, to: firstWeekDay){
                nextWeek.append(weekday)
            }
        }
    }
    
    func fetchOtherWeek(dir: SwipeDirection){
        switch(dir){
            case .prev:
                
                let d = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
                if isExpired(day: d){
                    selectedDate = Date()
                } else {
                    selectedDate = d
                }
                nextWeek.removeAll()
                nextWeek = curWeek
                curWeek = prevWeek
                updateWeek(value: -7)
            case .next:
                selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!
                prevWeek.removeAll()
                prevWeek = curWeek
                curWeek = nextWeek
                updateWeek(value: 7)
            case .none:
                selectedDate = selectedDate
        }
        
    }
    
    func updateWeek(value: Int){
        let week = Calendar.current.dateInterval(of: .weekOfMonth, for: selectedDate)
        guard let firstWeekDay = week?.start else {return }
        
        if value > 0{
            nextWeek.removeAll()
            (0...6).forEach{ day in
                if let weekday = Calendar.current.date(byAdding: .day, value: value + day, to: firstWeekDay){
                    nextWeek.append(weekday)
                }
            }
        } else {
            prevWeek.removeAll()

            (0...6).forEach{ day in
                if let weekday = Calendar.current.date(byAdding: .day, value: value + day, to: firstWeekDay){
                    prevWeek.append(weekday)
                }
            }
        }
        
    }
    
    func showDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    func isSameDay(d1: Date, d2: Date) -> Bool{
        let calendar = Calendar.current
        return calendar.isDate(d1, inSameDayAs: d2)
    }
    
    func isExpired(day: Date) -> Bool{
        return !self.isSameDay(d1: Date(), d2: day) && day < Date()
    }
   
    func isOutOfWeek() -> Bool{
        let day = Calendar.current.startOfDay(for: selectedDate)
        return !prevWeek.contains(day) && !curWeek.contains(day) && !nextWeek.contains(day)
    }
    
}

enum SwipeDirection {
    case prev
    case none
    case next
}

