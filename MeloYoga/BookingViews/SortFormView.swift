//
//  SortFormView.swift
//  MeloYoga
//

import SwiftUI

struct SortFormView: View {
    @EnvironmentObject var courseFilter: CourseFilter
    
    @State private var timeOption: TimeSortingOptions = .asc
    @State private var tnameOption: NameSortingOptions = .none
    @State private var cnameOption: NameSortingOptions = .none
    @State private var numOption: NumSortingOptions = .none
    
    func getSortSettings(){
        timeOption = courseFilter.timeOption
        tnameOption = courseFilter.tnameOption
        cnameOption = courseFilter.cnameOption
        numOption = courseFilter.numOption
    }
    
    var body: some View {
        
        NavigationStack {
            List{
                Picker("Time", selection: $courseFilter.timeOption) {
                    ForEach(TimeSortingOptions.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }.onAppear{
                    getSortSettings()
                }
                Picker("Type Name", selection: $courseFilter.tnameOption) {
                    ForEach(NameSortingOptions.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                Picker("Coach Name", selection: $courseFilter.cnameOption) {
                    ForEach(NameSortingOptions.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                Picker("Credits", selection: $courseFilter.numOption) {
                    ForEach(NumSortingOptions.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                Button{
                    courseFilter.defaultSorting()
                    getSortSettings()
                    courseFilter.sortUpdate()
                } label: {
                    HStack{
                        Spacer(); Text("Reset"); Spacer()
                    }
                }.listRowBackground(Color.bluebg)
                
                Section{
                    Button{
                        getSortSettings()
                        courseFilter.sortUpdate()
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
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.large)
            .onAppear{
                getSortSettings()
            }
            .onDisappear{
                courseFilter.timeOption = timeOption
                courseFilter.tnameOption = tnameOption
                courseFilter.cnameOption = cnameOption
                courseFilter.numOption = numOption
            }
        }
    }
}


//#Preview {
//    SortFormView()
//        .environmentObject(CourseFilter())
//}
struct SortFormPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
