//
//  FilterFormView.swift
//  MeloYoga
//

import SwiftUI

struct FilterFormView: View {
    @EnvironmentObject var courseFilter: CourseFilter
    @State var fromTime: Date = Date()
    @State var toTime: Date = Date()
    @State var selectedTypes: [String] = ["All"]
    @State var selectedCoaches: [String] = ["All"]
    @State var maxCred: Int = 10
    @State var minCred: Int = 0
    
    @State private var showingTypes:Bool = false
    @State private var showingCoaches:Bool = false
    @State private var showingWheel:Bool = false
    @State private var showingWheel2:Bool = false
    
    var selectedDate: Date
    
    func getFilterSettings(){
        fromTime = courseFilter.timeFrom
        toTime = courseFilter.timeTo
        selectedTypes = courseFilter.typeSelected
        selectedCoaches = courseFilter.coachSelected
        maxCred = courseFilter.maxCred
        minCred = courseFilter.minCred
    }
    
    var body: some View {
        
        NavigationStack {
            List{
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("Time").bold()
                    }.padding(.top, 7)
                    Spacer()
                    VStack{
                        DatePicker("From: ", selection: $fromTime, displayedComponents: .hourAndMinute)
                        DatePicker("To: ", selection: $toTime, displayedComponents: .hourAndMinute)
                    }.frame(width: 160)
                   
                }
                HStack(alignment: .center){
                    VStack{
                        Text("Type Name").bold()
                    }
                    Spacer()
                    Button{
                        showingTypes = true
                    } label: {
                        LazyHStack(alignment: .center){
                            Text("\(ListFormatter.localizedString(byJoining: selectedTypes))")
                                .multilineTextAlignment(.trailing)
                            Image(systemName: "chevron.right")
                        }
                    }
                    .popover(isPresented: $showingTypes, attachmentAnchor: .point(.bottomTrailing)){
                        MultiSelectPickerView(options: TypeFilterOptions.allValues, selections: $selectedTypes)
                            .frame(width: 250, height: 175)
                            .presentationCompactAdaptation(.popover)
                    }


                }
                HStack(alignment: .center){
                    VStack{
                        Text("Coach Name").bold()
                    }
                    Spacer()
                    Button{
                        showingCoaches = true
                    } label: {
                        LazyHStack(alignment: .center){
                            Text("\(selectedCoaches.joined(separator: " \n"))")
                                .multilineTextAlignment(.trailing)
                            Image(systemName: "chevron.right")
                        }
                    }
                    .popover(isPresented: $showingCoaches, attachmentAnchor: .point(.bottomTrailing), arrowEdge: .trailing){
                        MultiSelectPickerView(options: CoachFilterOptions.allValues, selections: $selectedCoaches)
                            .frame(minWidth: 250, minHeight: 175)
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("Credits").bold()
                    }.padding(.top, 1)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 10){
                        HStack{
                            Text("at most:")
                            Spacer()
                            Text("\(maxCred)")
                                .frame(width: 20, height: 20)
                                .padding(3)
                                .background(Color.bluebg2)
                                .cornerRadius(5)
                                .onTapGesture {
                                    showingWheel = true
                                }.popover(isPresented: $showingWheel, attachmentAnchor: .point(.center)){
                                    numberWheel(num: $maxCred)
                                        .frame(minWidth: 100, minHeight: 100)
                                        .presentationCompactAdaptation(.popover)
                                }
                            Text("cred")
                        }
                        
                        HStack{
                            Text("at least:")
                            Spacer()
                            Text("\(minCred)")
                                .frame(width: 20, height: 20)
                                .padding(3)
                                .background(Color.bluebg2)
                                .cornerRadius(5)
                                .onTapGesture {
                                    showingWheel2 = true
                                }.popover(isPresented: $showingWheel2, attachmentAnchor: .point(.center)){
                                    numberWheel(num: $minCred)
                                        .frame(minWidth: 100, minHeight: 100)
                                        .presentationCompactAdaptation(.popover)
                                }
                            Text("cred")
                        }
                    }
                    .frame(width: 160)
                    .onChange(of: maxCred){
                        if maxCred < minCred{
                            maxCred = minCred
                        }
                    }
                    .onChange(of: minCred){
                        if maxCred < minCred{
                            minCred = maxCred
                        }
                    }
                }
                
                Button{
                    withAnimation{
                        courseFilter.defaultFilter()
                        getFilterSettings()
                        courseFilter.filterUpdate(selectedDate: selectedDate, ft: fromTime, tt: toTime, st: selectedTypes, sc: selectedCoaches, max: maxCred, min: minCred)
                    }
                } label: {
                    HStack{
                        Spacer(); Text("Reset"); Spacer()
                    }
                }.listRowBackground(Color.bluebg)
                
                Section{
                    Button{
                        withAnimation{
                            courseFilter.filterUpdate(selectedDate: selectedDate, ft: fromTime, tt: toTime, st: selectedTypes, sc: selectedCoaches, max: maxCred, min: minCred)
                        }
                    } label: {
                        HStack{
                            Spacer(); Text("Apply"); Spacer()
                        }.foregroundStyle(Color.white)
                    }
                }.listRowBackground(Color.blueword)
                
            }.headerProminence(.increased)
            .foregroundStyle(Color.blueword)
            .fontWeight(.medium)
            .tint(Color.blueword)
            .navigationTitle("Filter By")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                getFilterSettings()
            }
        }
    }
}

struct numberWheel: View {
    @Binding var num: Int
    var body: some View {
        Picker("", selection: $num) {
            ForEach((0..<11).reversed(), id: \.self) {
                Text("\($0)")
            }
        }.frame(maxWidth: 100, maxHeight: 100)
        .pickerStyle(.wheel)
    }
}

//#Preview {
//    FilterFormView()
//        .environmentObject(CourseFilter())
//}
struct FilterFormPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
