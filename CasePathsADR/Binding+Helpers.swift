//
//  Binding+Helpers.swift
//  CasePathsADR
//
//  Created by Marcin Mucha on 31/01/2024.
//

import Foundation
import SwiftUI
import CasePaths

/// The helpers come from: https://github.com/pointfreeco/swiftui-navigation/blob/a7592b62e808b922c40fef5981cdbb9725ced0b2/Sources/SwiftUINavigation/Binding.swift
/// I included them separately to avoid adding the whole SwiftUINavigation library
/// They are useful for producing bindings to values held in (optional) enum state

//extension Binding {
//  public subscript<Member>(
//    dynamicMember keyPath: KeyPath<Value.AllCasePaths, AnyCasePath<Value, Member>>
//  ) -> Binding<Member>?
//  where Value: CasePathable {
//    let casePath = Value.allCasePaths[keyPath: keyPath]
//    return Binding<Member>(unwrapping:
//      Binding<Member?>(
//        get: { casePath.extract(from: self.wrappedValue) },
//        set: { newValue, transaction in
//          guard let newValue else { return }
//          self.transaction(transaction).wrappedValue = casePath.embed(newValue)
//        }
//      )
//    )
//  }
//
//  public subscript<Enum: CasePathable, Member>(
//    dynamicMember keyPath: KeyPath<Enum.AllCasePaths, AnyCasePath<Enum, Member>>
//  ) -> Binding<Member?>
//  where Value == Enum? {
//    let casePath = Enum.allCasePaths[keyPath: keyPath]
//    return Binding<Member?>(
//      get: {
//        guard let wrappedValue = self.wrappedValue else { return nil }
//        return casePath.extract(from: wrappedValue)
//      },
//      set: { newValue, transaction in
//        guard let newValue else {
//          self.transaction(transaction).wrappedValue = nil
//          return
//        }
//        self.transaction(transaction).wrappedValue = casePath.embed(newValue)
//      }
//    )
//  }
//}
//
//extension Binding {
//  public init?(unwrapping base: Binding<Value?>) {
//    self.init(unwrapping: base, case: /AnyCasePath.some)
//  }
//
//  private init?<Enum>(unwrapping enum: Binding<Enum>, case casePath: AnyCasePath<Enum, Value>) {
//    guard var `case` = casePath.extract(from: `enum`.wrappedValue)
//    else { return nil }
//
//    self.init(
//      get: {
//        `case` = casePath.extract(from: `enum`.wrappedValue) ?? `case`
//        return `case`
//      },
//      set: {
//        guard casePath.extract(from: `enum`.wrappedValue) != nil else { return }
//        `case` = $0
//        `enum`.transaction($1).wrappedValue = casePath.embed($0)
//      }
//    )
//  }
//}
