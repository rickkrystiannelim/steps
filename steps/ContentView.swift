//
//  ContentView.swift
//  steps
//
//  Created by Rick  Kystianne Lim on 11/17/20.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        VStack(
            alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
            spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/,
            content: {
                Text("Hello, world!")
                    .padding()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                
                Button(
                    action: {
                        if HKHealthStore.isHealthDataAvailable() {
                            print("HKHealthStore available")
                            // Add code to use HealthKit here.
                            let healthStore = HKHealthStore()
                        
                            guard let stepCountType = HKObjectType.quantityType(
                                forIdentifier: .stepCount
                            ) else {
                                fatalError("*** Unable to get the step count type ***")
                            }
                            
                            guard let distanceType = HKObjectType.quantityType(
                                forIdentifier: .distanceWalkingRunning
                            ) else {
                                fatalError("*** Unable to get the step count type ***")
                            }
                            
                            healthStore.requestAuthorization(
                                toShare: [],
                                read: Set([stepCountType, distanceType])
                            ) { (success, error) in
                                if success {
                                    print("Authorization OK")
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                    dateFormatter.timeZone = TimeZone.current
                                    dateFormatter.locale = Locale.current
                                    let startDate = dateFormatter.date(
                                        from: "2017-11-27T00:00:00"
                                    )
                                    
                                    var interval = DateComponents()
                                    interval.day = 1
                                        
//                                    let calendar = Calendar.current
//                                    let anchorDate = calendar.date(
//                                        bySettingHour: 12,
//                                        minute: 0,
//                                        second: 0,
//                                        of: Date()
//                                    )
                                    let anchorDate = dateFormatter.date(
                                        from: "2020-11-27T23:59:59"
                                    )!
                                    print(anchorDate)
                                    print(interval)
                                    
                                    let datePredicate = HKQuery.predicateForSamples(
                                        withStart: startDate,
                                        end: anchorDate
                                    )
                                    let sourcesQuery = HKSourceQuery.init(
                                        sampleType: stepCountType,
                                        samplePredicate: nil
                                    ) { (query, data, error) in
                                        let sources = data?.filter({
                                            !$0.bundleIdentifier.hasPrefix("com.apple.Health")
                                        })
                                        
                                        if sources != nil && sources!.isEmpty {
                                            return
                                        }
                                        
                                        let sourcesPredicate = HKQuery.predicateForObjects(
                                            from: sources!
                                        )
                                        let predicate = NSCompoundPredicate(
                                            andPredicateWithSubpredicates: [
                                                datePredicate,
                                                sourcesPredicate
                                            ]
                                        )
                                        let query = HKStatisticsCollectionQuery.init(
                                            quantityType: stepCountType,
                                            quantitySamplePredicate: nil,//predicate,
                                            options: .cumulativeSum,
                                            anchorDate: anchorDate,
                                            intervalComponents: interval
                                        )
                                        print(query)

                                        query.initialResultsHandler = {
                                            query,
                                            results,
                                            error in

                                            print(startDate!)
                                            print(anchorDate)

                                            var stepsValues = [String: Double]()

                                            results?.enumerateStatistics(
                                                from: startDate!,
                                                to: anchorDate,
                                                with: { (result, stop) in
                                                    result.sources?.forEach({ (source) in
                                                        print("-- soure: \(source.bundleIdentifier)")

                                                    })

                                                    stepsValues.updateValue(
                                                        result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0,
                                                        forKey: "\(result.startDate.addingTimeInterval(24 * 60 * 60))"
                                                    )
    //                                                stepsValues.append(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)

                                                    if (result.startDate.compare(anchorDate) == ComparisonResult.orderedSame) {
                                                        print("THE SAME. END")
                                                    }

                                                    print("Time: \(result.startDate.addingTimeInterval(24 * 60 * 60)), \(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)")
                                                }
                                            )
                                        }

                                        healthStore.execute(query)
                                        print("QUERY executed")
                                    }
                                    
                                    healthStore.execute(sourcesQuery)
                                } else {
                                    print("Authorization failed")
                                }
                            }
                        } else {
                            print("HKHealthStore NOT available")
                        }
                    },
                    label: {
                        Text("STEPS")
                    }
                ).padding()
                
                Button(
                    action: {
                        if HKHealthStore.isHealthDataAvailable() {
                            print("HKHealthStore available")
                            // Add code to use HealthKit here.
                            let healthStore = HKHealthStore()
                        
                            guard let stepCountType = HKObjectType.quantityType(
                                forIdentifier: .stepCount
                            ) else {
                                fatalError("*** Unable to get the step count type ***")
                            }
                            
                            guard let distanceType = HKObjectType.quantityType(
                                forIdentifier: .distanceWalkingRunning
                            ) else {
                                fatalError("*** Unable to get the step count type ***")
                            }
                            
                            healthStore.requestAuthorization(
                                toShare: [],
                                read: Set([stepCountType, distanceType])
                            ) { (success, error) in
                                if success {
                                    print("Authorization OK")
                                    
                                    healthKitQuery(
                                        dates: ["2017-11-27", "2020-11-27"],
                                        healthStore: healthStore,
                                        quantityType: stepCountType,
                                        unit: HKUnit.count()
                                    )
//                                    healthKitQuery(
//                                        dates: ["2020-11-25", "2020-11-25"],
//                                        healthStore: healthStore,
//                                        quantityType: distanceType,
//                                        unit: HKUnit.meter()
//                                    )
                                } else {
                                    print("Authorization failed")
                                }
                            }
                        } else {
                            print("HKHealthStore NOT available")
                        }
                    },
                    label: {
                        Text("STEPS 2")
                    }
                ).padding()
                
                Button(
                    action: {
                        if HKHealthStore.isHealthDataAvailable() {
                            print("HKHealthStore available")
                            // Add code to use HealthKit here.
                            let healthStore = HKHealthStore()
                            
                            guard let distanceType = HKObjectType.quantityType(
                                forIdentifier: .distanceWalkingRunning
                            ) else {
                                fatalError("*** Unable to get the step count type ***")
                            }
                            
                            healthStore.requestAuthorization(
                                toShare: [],
                                read: Set([distanceType])
                            ) { (success, error) in
                                if success {
                                    print("Authorization OK")
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                    dateFormatter.timeZone = TimeZone.current
                                    dateFormatter.locale = Locale.current
                                    let startDate = dateFormatter.date(
                                        from: "2017-11-25T00:00:00"
                                    )
                                    
                                    var interval = DateComponents()
                                    interval.day = 1
                                        
//                                    let calendar = Calendar.current
//                                    let anchorDate = calendar.date(
//                                        bySettingHour: 12,
//                                        minute: 0,
//                                        second: 0,
//                                        of: Date()
//                                    )
                                    let anchorDate = dateFormatter.date(
                                        from: "2020-11-25T23:59:59"
                                    )!
                                    print(anchorDate)
                                    print(interval)

                                    let query = HKStatisticsCollectionQuery.init(
                                        quantityType: distanceType,
                                        quantitySamplePredicate: nil,
                                        options: .cumulativeSum,
                                        anchorDate: anchorDate,
                                        intervalComponents: interval
                                    )
                                    print(query)
                                        
                                    query.initialResultsHandler = {
                                        query,
                                        results,
                                        error in
                                        
                                        print(startDate!)
                                        print(anchorDate)
                                        
                                        var distanceValues = [String: Double]()
                                        
                                        results?.enumerateStatistics(
                                            from: startDate!,
                                            to: anchorDate,
                                            with: { (result, stop) in
                                                distanceValues.updateValue(
                                                    result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0,
                                                    forKey: "\(result.startDate.addingTimeInterval(24 * 60 * 60))"
                                                )
//                                                stepsValues.append(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                                                
                                                if (result.startDate.compare(anchorDate) == ComparisonResult.orderedSame) {
                                                    print("THE SAME. END")
                                                }
                                                
                                                print("STOP: \(stop.pointee.boolValue)")
                                                print("Time: \(result.startDate.addingTimeInterval(24 * 60 * 60)), \(result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0)")
                                            }
                                        )
                                    }
                                    healthStore.execute(query)
                                    print("QUERY executed")
                                } else {
                                    print("Authorization failed")
                                }
                            }
                        } else {
                            print("HKHealthStore NOT available")
                        }
                    },
                    label: {
                        Text("DISTANCE")
                    }
                ).padding()
            }
        )
    }
    
    private func healthKitQuery(
        dates: Array<String>,
        healthStore: HKHealthStore,
        quantityType: HKQuantityType,
        unit: HKUnit
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        let dateKeyFormatter = DateFormatter()
        dateKeyFormatter.dateFormat = "yyyy-MM-dd"
        dateKeyFormatter.timeZone = TimeZone.current
        dateKeyFormatter.locale = Locale.current
        
        let startDate = dateFormatter.date(
            from: "\(dates[0])T00:00:00"
        )!
        let anchorDate = dateFormatter.date(
            from: "\(dates[1])T23:59:59"
        )!
        
        var interval = DateComponents()
        interval.day = 1
        
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: anchorDate
        )
        let sourcesQuery = HKSourceQuery.init(
            sampleType: quantityType,
            samplePredicate: datePredicate
        ) { (query, sources, error) in
            sources?.forEach({ (shit) in
                print("shit = \(shit.bundleIdentifier)")
            })
            
            let filteredSources = sources?.filter({
                !$0.bundleIdentifier.hasPrefix("com.apple.Health")
            })
            
            if filteredSources == nil {
                return
            } else if filteredSources!.isEmpty {
                print("NO DATA! DONE...")
                return
            }
            
            // Only calculate HealthKit data whose not from
            // "com.apple.Health" app. (Manually inputted)
            let sourcesPredicate = HKQuery.predicateForObjects(
                from: filteredSources!
            )
            let wasUserEnteredPredicate = HKQuery.predicateForObjects(
                withMetadataKey: "HKWasUserEntered"
            )
            let predicate = NSCompoundPredicate.init(
                andPredicateWithSubpredicates: [
                    datePredicate,
                    sourcesPredicate,
                    NSCompoundPredicate(
                        notPredicateWithSubpredicate: wasUserEnteredPredicate
                    )
                ]
            )
            let query = HKStatisticsCollectionQuery.init(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )
                
            query.initialResultsHandler = {
                query,
                results,
                error in

                var data = [String]()

                results?.enumerateStatistics(
                    from: startDate,
                    to: anchorDate,
                    with: { (queryResult, stop) in
                        let value = queryResult.sumQuantity()?.doubleValue(for: unit) ?? 0

                        if value > 0 {
                            data.append("\(dateKeyFormatter.string(from: queryResult.startDate.addingTimeInterval(24 * 60 * 60))),\(value)")
                        }

                        if (queryResult.startDate.compare(anchorDate) == ComparisonResult.orderedSame) {
                            print(data)
                            print("DONE!")
                        }
                    }
                )
            }
            
            healthStore.execute(query)
        }
        
        healthStore.execute(sourcesQuery)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
