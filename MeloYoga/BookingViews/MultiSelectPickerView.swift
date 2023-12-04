//
//  MultiSelectPickerView.swift
//  MeloYoga
//

import SwiftUI

struct MultiSelectPickerView: View {
    var options: [String]
    @Binding var selections:[String]
    
    var body: some View {
        List{
            ForEach(options, id: \.self){ option in
                Button{
                    if option == "All"{
                        selections.removeAll(where: {$0 != option})
                        if !selections.contains(option){
                            selections.append(option)
                        }
                    } else if selections.contains(option){
                        selections.removeAll(where: {$0 == option})
                    } else {
                        selections.append(option)
                        selections.removeAll(where: {$0 == "All"})
                        if selections.count == 3 {
                            selections.removeAll(where: {$0 != "All"})
                            selections.append("All")
                        }
                        
                    }
                } label: {
                    HStack{
                        Text(option)
                        Spacer()
                        if selections.contains(option){
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }.listStyle(.inset)
    }
}

//#Preview {
//    MultiSelectPickerView(options: TypeFilterOptions.allValues)
//}

struct MultiSelectPickerPreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
