import Foundation

class Person {
    
    let name: String
    
    private var isWorking: Bool = false
    
    var workHandler: ((String) -> Void)?

    init(name: String) {
        self.name = name
        print("--> init person, name: \(name)")
    }
    
    deinit {
        print("--> deinit")
    }
    
    func startWorking() {
        isWorking = true
        workHandler?(name)
    }
    
}

class A {
    
    let person = Person(name: "Tom")
    
    let job = "write code"
    
    func work() {
        // MARK: use [job] to capture only his `job` without capturing self
        person.workHandler = { [job] name in
            print("Worker \(name) is now working on: \(job)")
        }
        person.startWorking()
    }
    
}

func work() {
    let a = A()
    a.work()
}

work()
