//
//  RectKey.swift
//  DarkModeAnimation
//
//  Created by Ray on 2023/12/30.
//

import SwiftUI

struct RectKey: PreferenceKey {
  
  static var defaultValue: CGRect = .zero
  
  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}
