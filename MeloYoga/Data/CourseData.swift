//
//  CourseDataModel.swift
//  MeloYoga
//

import Foundation

struct CourseData: Identifiable, Decodable {
    var id: Int
    var name: String
    var coach: String
    var cred: Int16
    var type: String

}

struct CourseWeekData: Identifiable, Decodable {
    var id: Int
    var name: String
    var coach: String
    var cred: Int16
    var type: String
    var weekday: String
    var startTime: String
    var endTime: String
}


