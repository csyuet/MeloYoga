//
//  WeeksView.swift
//  MeloYoga
//

import SwiftUI

struct WeeksView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @State var weekIndex = 1
    @State var direction: SwipeDirection = .none
    
    var body: some View {
    
        HStack(spacing: 0) {
            Spacer()
            Button{
                withAnimation {
                    weekIndex -= 1
                }
            }label: {
                Image(systemName: "chevron.left")
            }
            
            TabView(selection: $weekIndex) {
                
                WeekView(week: calendarViewModel.prevWeek)
                    .environmentObject(calendarViewModel)
                    .tag(0)
                    
                WeekView(week: calendarViewModel.curWeek)
                    .environmentObject(calendarViewModel)
                    .tag(1)
                    .onDisappear() {
                        guard direction != .none else { return }
                        calendarViewModel.fetchOtherWeek(dir: direction)
                        direction = .none
                        weekIndex = 1
                    }
                
                WeekView(week: calendarViewModel.nextWeek)
                    .environmentObject(calendarViewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            Button{
                withAnimation {
                    weekIndex += 1
                }
            }label: {
                Image(systemName: "chevron.right")
            }
            Spacer()
        }
        .onChange(of: weekIndex){
            if weekIndex == 0 {
                direction = .prev
            } else if weekIndex == 2{
                direction = .next
            }
        }
        .onChange(of: calendarViewModel.selectedDate){
            withAnimation {
                calendarViewModel.fetchWeeks(date: calendarViewModel.selectedDate)
            }
        }

    }
}

#Preview {
    WeeksView()
        .environmentObject(CalendarViewModel())
}
