//
//  PaymentSummaryView.swift
//  CasePathsADR
//
//  Created by Marcin Mucha on 07/02/2024.
//

import SwiftUI
import CasePaths
import SwiftUINavigation

final class PaymentSummaryViewModel: ObservableObject {
  @Published var method: PaymentMethod = .cardReader

  @Published var destination: Destination?

  init(method: PaymentMethod) {
    self.method = method
  }

  @CasePathable
  @dynamicMemberLookup
  enum PaymentMethod {
    case cardReader
    case cardOnFileSavedEmail(isEnabled: Bool, email: String)
    case cardOnFile(isEnabled: Bool, newEmail: String)
  }

  @CasePathable
  enum Destination {
    case payAlert(context: String)
    case paySheet(context: String)
  }

  func didTapPayShowAlert() {
    destination = .payAlert(context: navigationContext)
  }

  func didTapPayShowSheet() {
    destination = .paySheet(context: navigationContext)
  }

  private var navigationContext: String {
    switch method {
    case .cardOnFile:
      "Card on File"
    case .cardOnFileSavedEmail:
      "Card on File with saved email"
    case .cardReader:
      "Card reader"
    }
  }
}

struct PaymentSummaryView: View {
  @ObservedObject var viewModel: PaymentSummaryViewModel

  var body: some View {
    Form {
      switch viewModel.method {
      case .cardReader:
        CardReaderView()
      case .cardOnFileSavedEmail:
        $viewModel.method.cardOnFileSavedEmail.map { $cardOnFileSavedEmail in
          CardOnFileEmailSavedView(isEnabled: $cardOnFileSavedEmail.isEnabled, email: $cardOnFileSavedEmail.email.wrappedValue)
        }
      case .cardOnFile:
        $viewModel.method.cardOnFile.map { $cardOnFile in
          CardOnFileView(isEnabled: $cardOnFile.isEnabled, email: $cardOnFile.newEmail)
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      VStack {
        Text("Disclaimer: \(disclaimer)")
        Button("Pay (show alert)") {
          viewModel.didTapPayShowAlert()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isPayEnabled)

        Button("Pay (show sheet)") {
          viewModel.didTapPayShowSheet()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isPayEnabled)
      }
    }
    .alert(
      title: { context in
        Text(context)
      },
      unwrapping: $viewModel.destination.payAlert,
      actions: { _ in
        Button("Cancel") {
          viewModel.destination = nil
        }
      }, message: { context in
        Text("Do you want pay with \(context)?")
      })
    .sheet(
      unwrapping: $viewModel.destination.paySheet,
      onDismiss: { viewModel.destination = nil },
      content: { $context in Text("Do you want pay with \($context.wrappedValue)?") }
    )
  }

  private var isPayEnabled: Bool {
    switch viewModel.method {
    case .cardOnFile(_, let email), .cardOnFileSavedEmail(_, let email):
      return !email.isEmpty
    case .cardReader:
      return true
    }
  }

  private var disclaimer: String {
    switch viewModel.method {
    case .cardOnFile(let isEnabled, _) where isEnabled == true, .cardOnFileSavedEmail(let isEnabled, _) where isEnabled == true:
      "I authorize saving card on file."
    default:
      "I authorize a regular payment."
    }
  }
}

private struct CardReaderView: View {
  var body: some View {
    Group {
      Text("Card reader")
    }
  }
}

private struct CardOnFileEmailSavedView: View {
  @Binding var isEnabled: Bool
  var email: String

  var body: some View {
    Group {
      Section("Card on file (email available)") {
        HStack {
          Text("Email")
          Spacer()
          Text(email)
        }
      }
      Section("Save card on file") {
        Toggle(isOn: $isEnabled) {
          Text("Save card on file")
        }
      }
    }
  }
}

private struct CardOnFileView: View {
  @Binding var isEnabled: Bool
  @Binding var email: String

  var body: some View {
    Group {
      Section("Card on file (email available)") {
        TextField("Email:", text: $email)
          .textFieldStyle(.roundedBorder)
      }
      Section("Save card on file") {
        Toggle(isOn: $isEnabled) {
          Text("Save card on file")
        }
      }
    }
  }
}

#Preview("Card reader") {
  PaymentSummaryView(viewModel: .init(method: .cardReader))
}

#Preview("Card on file with available email") {
  PaymentSummaryView(viewModel: .init(method: .cardOnFileSavedEmail(isEnabled: false, email: "fintech.mobile@housecallpro.com")))
}

#Preview("Card on file with no email") {
  PaymentSummaryView(viewModel: .init(method: .cardOnFile(isEnabled: false, newEmail: "")))
}
