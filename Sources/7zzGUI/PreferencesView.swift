import SwiftUI

struct PreferencesView: View {
    @Environment(LocaleManager.self) private var locale

    var body: some View {
        TabView {
            Form {
                Picker(locale.t("pref.language"), selection: Binding(
                    get: { locale.language },
                    set: { locale.language = $0 }
                )) {
                    ForEach(locale.availableLanguages, id: \.code) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            }
            .padding(20)
            .tabItem { Label(locale.t("pref.language"), systemImage: "globe") }
        }
        .frame(width: 360, height: 140)
    }
}
