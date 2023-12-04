//
//  Persistence.swift
//  MeloYoga
//

import CoreData

let costs: [Int16] = [888, 1388,2188,2688,4788, 7888]
let tcreds: [Int16] = [30, 50, 80, 100, 180, 300]
let expiry: [Int16] = [1, 1, 3, 4, 6, 12]
let weekdays:[String] = ["Sunday", "Monday", "Tuesday", "Wednsday", "Thursday", "Friday", "Saturday"]

struct CourseStruct {
    var name: String
    var coach: String
    var cred: Int16
    var type: String
    
    init(name: String, coach: String, cred: Int16, type: String) {
        self.name = name
        self.coach = coach
        self.cred = cred
        self.type = type
    }
}

let Courses = [CourseStruct(name: "Spinnging Hammock",
                          coach: "Rain Mo",
                          cred: 6,
                          type: "Aerial"),
               CourseStruct(name: "Hatha Yoga",
                          coach: "Valetta Cheung",
                          cred: 4,
                          type: "Yoga"),
               CourseStruct(name: "Wheel Yoga",
                          coach: "Rain Mo",
                          cred: 4,
                          type: "Yoga"),
               CourseStruct(name: "Deep Stretch",
                          coach: "Katia Kwok",
                          cred: 4,
                          type: "Yoga"),
               CourseStruct(name: "Hoop",
                          coach: "Katia Kwok",
                          cred: 6,
                          type: "Aerial"),
               CourseStruct(name: "Aerial Yoga",
                          coach: "Valetta Cheung",
                          cred: 5,
                          type: "Aerial")
            ]

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<20 {
            let course = CourseOfWeek(context: viewContext)
            let c = Courses.randomElement()!
            course.id = UUID()
            course.name = c.name
            course.coach = c.coach
            course.cred = c.cred
            course.type = c.type
            var h = Int.random(in: 10...22)
            let m: Int = [00,30].randomElement()!
            course.startTime = String(h) + String(format: "%02d", m)
            h = h + 1
            course.endTime = String(h) + String(format: "%02d", m)
            course.weekday = weekdays.randomElement()
        }
        
        let user = User(context: viewContext)
        user.id = UUID()
        user.name = "Victor Lee"
        user.phone = "9876 5432"
        user.email = "csvlee@eee.hku.hk"
        user.pw = "1234"
        user.login = true
        
        for i in 0..<costs.count {
            let package = Package(context: viewContext)
            package.id = UUID()
            package.cost = costs[i]
            package.totalCredit = tcreds[i]
            package.expiry = expiry[i]
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MeloYoga")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
