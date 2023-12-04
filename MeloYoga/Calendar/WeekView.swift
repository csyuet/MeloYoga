//
//  WeekView.swift
//  MeloYoga
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    var week: [Date]
    var enabled: Bool = true
    
    var body: some View {
        HStack(alignment: .center, spacing: 5){
            
//            ForEach(calendarViewModel.curWeek, id: \.self){ day in
            ForEach(week, id: \.self){ day in
                VStack(spacing: 10){
                    Text(calendarViewModel.showDate(date: day, format: "E"))
                        .fontWeight(calendarViewModel.isSameDay(d1: Date(), d2: day) ? .heavy : .bold)
                    Text(calendarViewModel.showDate(date: day, format: "d"))
                        .fontWeight(calendarViewModel.isSameDay(d1: Date(), d2: day) ? .heavy : .medium)
                }
                .opacity(calendarViewModel.isExpired(day: day) ? 0.3 : 1)
                .onTapGesture {
                    if !calendarViewModel.isExpired(day: day) && enabled{
                        withAnimation(.easeIn) {
                            calendarViewModel.selectedDate = day
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background {
                    ZStack{
                        if calendarViewModel.isSameDay(d1: calendarViewModel.selectedDate, d2: day){
                            Color.bluebg
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }

    }
}

#Preview {
    WeekView(week: [Date()])
        .environmentObject(CalendarViewModel())
}
