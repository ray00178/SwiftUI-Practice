//
//  View+Extension.swift
//  DarkModeAnimation
//
//  Created by Ray on 2023/12/30.
//

import SwiftUI

extension View {
  @ViewBuilder
  func rect(value: @escaping (CGRect) -> Void) -> some View {
    overlay {
      GeometryReader { geometry in
        let rect = geometry.frame(in: .global)

        Color.clear
          .preference(key: RectKey.self, value: rect)
          .onPreferenceChange(RectKey.self, perform: { rect in
            value(rect)
          })
      }
    }
  }

  @MainActor
  @ViewBuilder
  func createImages(toggleDarkMode: Bool,
                    currentImage: Binding<UIImage?>,
                    previousImage: Binding<UIImage?>,
                    activeteDarkMode: Binding<Bool>) -> some View
  {
    self
      .onChange(of: toggleDarkMode) { oldValue, newValue in
        Task {
          if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
            $0.isKeyWindow
          }) {
            let imageView = UIImageView()
            imageView.frame = window.frame
            imageView.image = window.rootViewController?.view.image(window.frame.size)
            imageView.contentMode = .scaleAspectFit
            window.addSubview(imageView)
            
            if let rootView = window.rootViewController?.view {
              let frameSize = rootView.frame.size
              activeteDarkMode.wrappedValue = !newValue
              previousImage.wrappedValue = rootView.image(frameSize)
              
              // New One
              activeteDarkMode.wrappedValue = newValue
              try await Task.sleep(for: .seconds(0.01))
              currentImage.wrappedValue = rootView.image(frameSize)
              
              // Remove image view
              try await Task.sleep(for: .seconds(0.01))
              imageView.removeFromSuperview()
            }
          }
        }
      }
  }
}

// MARK: - Convertiing to UIImage

extension UIView {
  
  func image(_ size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      drawHierarchy(in: .init(origin: .zero, size: size), afterScreenUpdates: true)
    }
  }
  
}
