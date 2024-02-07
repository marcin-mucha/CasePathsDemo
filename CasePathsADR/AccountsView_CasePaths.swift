//
//  AccountsView_CasePaths.swift
//  CasePathsADR
//
//  Created by Marcin Mucha on 31/01/2024.
//

import Foundation
import SwiftUI
import Combine
import CasePaths

@MainActor
class AccountViewModel_CasePaths: ObservableObject {
  @CasePathable
  @dynamicMemberLookup
  enum State: Equatable {
    case initial
    case loading
    case error
    case loaded(accounts: [String], selectedAccount: String?, amount: String)
  }

  enum LoadedState {
    case loading
    case error
  }

  enum Destination {

  }

  @Published var state: State = .initial

  func loadAccounts() async throws {
    state = .loading
    try await Task.sleep(for: .seconds(2))
    let accounts = ["Account 1", "Account 2", "Account 3", "Account 4"]
    state = .loaded(accounts: accounts, selectedAccount: nil, amount: "0")
  }

  private var cancellable: AnyCancellable?

  init() {
    cancellable = $state.print().sink{ _ in }

    // 1. We can check if the enum is in a specific case:
    if state.is(\.initial) {

    }

    // 2. We can read associated values directly using dot syntax:
    if let account = state.loaded?.accounts {

    }

//    state.modify(\.loaded) {
//      $0.amount = "00"
//    }

//     state[case: \.loaded]
  }
}

struct AccountView_CasePaths: View {
  @ObservedObject var viewModel: AccountViewModel_CasePaths

  var body: some View {
    switch viewModel.state {
    case .initial:
      Button("Load accounts") {
        Task {
          try? await viewModel.loadAccounts()
        }
      }
    case .loading:
      ProgressView()
    case .error:
      VStack {
        Text("Error")
        Button("Reload") {
          Task {
            try? await viewModel.loadAccounts()
          }
        }
      }
    case .loaded(let accounts, _, _):
      // $view.state.loaded is now a binding that we can use 🟢
      $viewModel.state.loaded.map { $loaded in
        VStack {
          Picker("Account:", selection: $loaded.selectedAccount) {
            Text("No account").tag(nil as String?)
            ForEach(accounts) { account in
              Text(account).tag( account as String?)
            }
          }
          TextField("Amount:", text: $loaded.amount)
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: 200)
        }
      }
    }
  }
}

//struct LoadedView: View {
//  @Binding var selectedAccount: String?
//  @Binding var amount: String
//}

#Preview {
  AccountView_CasePaths(viewModel: AccountViewModel_CasePaths())
}
