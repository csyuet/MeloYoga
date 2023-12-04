//
//  CourseDataModel.swift
//  MeloYoga
//

import Foundation

class CourseDataModel: ObservableObject {
    @Published var courses = [CourseData]()
    @Published var wcourses = [CourseWeekData]()
    
    init() {
        let pathString = Bundle.main.path(forResource: "data", ofType: "json")
        if let path = pathString{
            let url = URL(filePath: path)
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                do {
                    let courseData = try decoder.decode([CourseData].self, from: data)
                    self.courses = courseData
                }
                catch{
                    print(error)
                }
            }
            catch{
                print(error)
            }
        }
        
        let pathString2 = Bundle.main.path(forResource: "cdata", ofType: "json")
        if let path = pathString2{
            let url = URL(filePath: path)
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                do {
                    let courseWeekData = try decoder.decode([CourseWeekData].self, from: data)
                    self.wcourses = courseWeekData
                }
                catch{
                    print(error)
                }
            }
            catch{
                print(error)
            }
        }
    }
}


