import Foundation

class Person {
    
    let name: String
    
    var workHandler: ((String) -> Void)?

    init(name: String) {
        self.name = name
        print("--> init: \(name)")
    }
    
    deinit {
        print("--> deinit: \(self.name)")
    }
    
    func startWorking() {
        workHandler?(name)
    }
    
}

class A {
    
    init(_ personName: String, job: String) {
        self.person = Person(name: personName)
        self.job = job
    }
    
    let person: Person
    
    let job: String
    
}

// MARK: - Here are 3 methods that break the retain cycle
//              and 1 method that break the programming
//              and 1 method that cause the retain cycle
extension A {
    func workWithoutRetainCycleByCapturingJob() {
        // MARK: use [job] to capture only his `job` without capturing self
        person.workHandler = { [job] name in
            print("Worker \(name) is now working on: \(job)")
        }
        person.startWorking()
    }
    
    func workWithoutRetainCycleByWeakCapturingSelf() {
        // use [weak self] to make weak reference to self
        person.workHandler = { [weak self] name in
            guard let self = self else { return }
            print("Worker \(name) is now working on: \(self.job)")
        }
        person.startWorking()
    }
    
    func workWithoutRetainCycleByUnownedCapturingSelf() {
        // use [unowned self] to make unowned reference to self
        person.workHandler = { [unowned self] name in
            print("Worker \(name) is now working on: \(self.job)")
        }
        person.startWorking()
    }

    func workAsyncWithoutRetainCycleByUnownedCapturingSelf() {
        // use [unowned self] to make unowned reference to self
        // MARK: this may cause the program failed with `unexpected found nil` if self is already deinit when runnin this function
        person.workHandler = { [unowned self] name in
            DispatchQueue.global(qos: .background).async {
                print("\nAsync...")
                print("Worker \(name) is now working on: \(self.job)")
            }
        }
        person.startWorking()
    }
    
    func workWithRetainCycle() {
        // MARK: default capture will make a Strong reference to what it captured
        person.workHandler = { name in
            print("Worker \(name) is now working on: \(self.job)")
        }
        person.startWorking()
    }
    
}

func work() {
    let a = A("Tom", job: "Write code")
    a.workWithoutRetainCycleByCapturingJob()
    
    let b = A("Tim", job: "Write code")
    b.workWithoutRetainCycleByWeakCapturingSelf()
    
    let c = A("Jack", job: "Write code")
    c.workWithoutRetainCycleByUnownedCapturingSelf()
    
    let d = A("Jerry", job: "Write code")
    d.workAsyncWithoutRetainCycleByUnownedCapturingSelf()
    
    let e = A("Mike", job: "Write code") // Mike will never be deinited
    e.workWithRetainCycle()
}

work()
