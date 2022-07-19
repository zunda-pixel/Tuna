import SwiftUI

extension View {
  func refreshableView(threshold: CGFloat = 200) -> some View {
    self.modifier(RefreshableModifier(threshold: threshold))
  }
}

struct RefreshableModifier: ViewModifier {
  @Environment(\.refresh) var refresh
  @State var isRefreshing: Bool?
  let threshold: CGFloat

  func body(content: Content) -> some View {
    VStack {
      if isRefreshing == true {
        ProgressView()
          .transition(.scale)
      }

      content
    }
    .animation(.default, value: isRefreshing)
    .background(
      GeometryReader { proxy in
        Color.clear.preference(key: ViewOffsetKey.self, value: -proxy.frame(in: .global).origin.y)
      }
    )
    .onPreferenceChange(ViewOffsetKey.self) { offset in
      guard isRefreshing != nil else {
        isRefreshing = false
        return
      }

      guard isRefreshing != true else { return }
      guard offset < -threshold else { return }

      isRefreshing = true

      Task {
        await refresh?()
        await MainActor.run {
          isRefreshing = false
        }
      }
    }
  }
}


struct ViewOffsetKey: PreferenceKey {
  public typealias Value = CGFloat
  public static var defaultValue = CGFloat.zero
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
