//
//  AccountsView.swift
//  CasePathsADR
//
//  Created by Marcin Mucha on 31/01/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AccountViewModel: ObservableObject {
  enum State {
    case initial
    case loading
    case error
    case loaded(accounts: [String], selectedAccount: String?, amount: String)
  }

  @Published var state: State = .initial

  func loadAccounts() async throws {
    state = .loading
    try await Task.sleep(for: .seconds(2))
    if Bool.random() {
      let accounts = ["Account 1", "Account 2", "Account 3", "Account 4"]
      state = .loaded(accounts: accounts, selectedAccount: nil, amount: "0")
    } else {
      state = .error
    }
  }

  private var cancellable: AnyCancellable?

  init() {
    cancellable = $state.print().sink{ _ in }
  }
}

extension String: Identifiable {
  public var id: Self { self }
}

struct AccountView: View {
  @ObservedObject var viewModel: AccountViewModel

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
    case .loaded(let accounts, let selectedAccount, let amount):
      VStack {
        // $selectedAccount doesn't work, it's not a binding 🔴
        // $viewModel.state.loaded ??? -> it doesn't work, we cannot access an enum case like this 🔴
        Picker("Account:", selection: Binding(get: {
          selectedAccount
        }, set: {
          viewModel.state = .loaded(accounts: accounts, selectedAccount: $0, amount: amount)
        })) {
          Text("No account").tag(nil as String?)
          ForEach(accounts) { account in
            Text(account).tag(account as String?)
          }
        }
        // $amount doesn't work, it's not a binding 🔴
        // $viewModel.state.amount ??? -> it doesn't work, we cannot access an enum case like this 🔴
        TextField("Amount:", text: Binding(get: {
          amount
        }, set: {
          viewModel.state = .loaded(accounts: accounts, selectedAccount: selectedAccount, amount: $0)
        }))
        .textFieldStyle(.roundedBorder)
        .frame(maxWidth: 200)
      }
    }
  }
}

#Preview {
  AccountView(viewModel: AccountViewModel())
}
