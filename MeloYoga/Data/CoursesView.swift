//
//  CoursesView.swift
//  MeloYoga
//

import SwiftUI

struct CoursesView: View {
    var course: Course
    
    var body: some View {
        
        VStack(alignment: .center){
            Text(course.startTime!, formatter: itemFormatter(format: "EE"))
                .font(.system(size: 20))
            Text(course.startTime!, formatter: itemFormatter(format: "dd"))
                .font(.system(size: 25)).fontWeight(.bold)
            Text(course.startTime!, formatter: itemFormatter(format: "MMM"))
                .font(.system(size: 15))
        }
        .frame(width: 80, height: 80)
        .background(Color.bluebg)
        .cornerRadius(10)
        VStack{
            Text(course.startTime!, formatter: itemFormatter(format: "t"))
            Text("|")
            Text(course.endTime!, formatter: itemFormatter(format: "t"))
        }
        VStack(alignment: .leading){
            Text(course.parent!.type!.uppercased())
            Text(course.parent!.name!)
                .font(.headline)
            Text("w/ \(course.parent!.coach!)")
        }
        Spacer(minLength: 50)
    }
}

//#Preview {
//    CoursesView()
//        .environmentObject(CourseDataModel())
//}

//#Preview {
//    HomeView(userIndex: 0)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        
//}

//struct HomeViewPreview: PreviewProvider{
//    static var previews: some View{
//        HomeView(userIndex: 0)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
