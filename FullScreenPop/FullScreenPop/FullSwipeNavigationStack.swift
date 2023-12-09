//
//  FullSwipeNavigationStack.swift
//  FullScreenPop
//
//  Created by Ray on 2023/12/9.
//

import SwiftUI

// MARK: - FullSwipeNavigationStack

/// Custom View
struct FullSwipeNavigationStack<Content: View>: View {
  @ViewBuilder var content: Content

  /// Full Swipe Custom Gesture
  @State private var swipeGesture: UIPanGestureRecognizer = {
    let pan = UIPanGestureRecognizer()
    pan.name = UUID().uuidString
    pan.isEnabled = false

    return pan
  }()

  var body: some View {
    NavigationStack {
      content
        .background {
          AttachGestureView(gesture: $swipeGesture)
        }
    }
    .environment(\.popGestureID, swipeGesture.name)
    .onReceive(NotificationCenter.default.publisher(
      for: .init(swipeGesture.name ?? "")),
    perform: { info in
      if let userInfo = info.userInfo,
         let status = userInfo["status"] as? Bool
      {
        swipeGesture.isEnabled = status
      }
    })
  }
}

// MARK: - AttachGestureView

private struct AttachGestureView: UIViewRepresentable {
  @Binding var gesture: UIPanGestureRecognizer

  func makeUIView(context _: Context) -> UIView {
    UIView()
  }

  func updateUIView(_ uiView: UIView, context _: Context) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
      // Finding parent controller
      if let parentViewController = uiView.parentViewController {
        if let navigationController = parentViewController.navigationController {
          // Checking if already the gesture has been added to controller
          if let _ = navigationController.view.gestureRecognizers?.first(where: { $0.name == gesture.name }) {
          } else {
            navigationController.addFullSwipeGesture(gesture)
          }
        }
      }
    }
  }
}

// MARK: - PopNotificationID

/// Custom Environment Key for Passing Gesture ID to it's subviews!
private struct PopNotificationID: EnvironmentKey {
  static var defaultValue: String?
}

private extension EnvironmentValues {
  var popGestureID: String? {
    get {
      self[PopNotificationID.self]
    }

    set {
      self[PopNotificationID.self] = newValue
    }
  }
}

extension View {
  @ViewBuilder
  func enableFullSwipePop(_ isEnable: Bool) -> some View {
    modifier(FullSwipeModifier(isEnable: isEnable))
  }
}

// MARK: - FullSwipeModifier

private struct FullSwipeModifier: ViewModifier {
  var isEnable: Bool

  /// Environment Gesture ID
  @Environment(\.popGestureID) private var popGestureID

  func body(content: Content) -> some View {
    content
      .onChange(of: isEnable, initial: true) { _, newValue in
        guard let popGestureID else { return }

        NotificationCenter.default.post(
          name: .init(popGestureID),
          object: nil,
          userInfo: ["status": newValue]
        )
      }
      .onDisappear {
        guard let popGestureID else { return }

        NotificationCenter.default.post(
          name: .init(popGestureID),
          object: nil,
          userInfo: ["status": false]
        )
      }
  }
}

private extension UINavigationController {
  func addFullSwipeGesture(_ geature: UIPanGestureRecognizer) {
    guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets")
    else {
      return
    }

    geature.setValue(gestureSelector, forKey: "targets")
    view.addGestureRecognizer(geature)
  }
}

private extension UIView {
  var parentViewController: UIViewController? {
    sequence(first: self) {
      $0.next
    }.first { $0 is UIViewController } as? UIViewController
  }
}

#Preview {
  ContentView()
}
