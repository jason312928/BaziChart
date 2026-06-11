import SwiftUI

struct SettingsView: View {
    @Bindable var store: DivinationStore

    var body: some View {
        Form {
            TextField("默认命主", text: $store.name)

            Picker("默认性别", selection: $store.gender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 420)
    }
}
