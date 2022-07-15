import SwiftUI

struct RefreshableView: ViewModifier {
  @State var isRefreshing = false

  let threshold: CGFloat
  let action: () async -> Void

  init(action: @escaping () async -> Void, threshold: CGFloat = 200) {
    self.action = action
    self.threshold = threshold
  }

  func body(content: Content) -> some View {
    VStack {
      if isRefreshing {
        ProgressView()
          .padding(.vertical)
          .transition(.scale)
      }

      content
    }
    .animation(.default, value: isRefreshing)
    .background(GeometryReader { proxy in
      Color.clear.preference(key: ViewOffsetKey.self, value: -proxy.frame(in: .global).origin.y)
    })
    .onPreferenceChange(ViewOffsetKey.self) { offset in
      guard offset < -threshold && !isRefreshing else { return }
      isRefreshing.toggle()

      Task {
        await action()
        isRefreshing.toggle()
      }
    }
  }
}

extension View {
  func anyRefreshable(action: @escaping () async -> Void) -> some View {
    self.modifier(RefreshableView(action: action))
  }
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
