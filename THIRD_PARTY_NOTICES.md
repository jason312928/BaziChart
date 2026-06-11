# Third-Party Notices

BaziChart includes or derives data from the following open-source projects.

## lunar-swift

- Project: <https://github.com/6tail/lunar-swift>
- Revision: `a7ec0e9b29f84a5d98b09b9ffd31145f17470d56`
- License: MIT
- Copyright: 2023 6tail

The complete upstream license is included in [`THIRD_PARTY_LUNAR_SWIFT_LICENSE`](THIRD_PARTY_LUNAR_SWIFT_LICENSE).

## province-city-china

- Project: <https://github.com/uiwjs/province-city-china>
- Dataset version: 8.5.8
- License: MIT
- Use in this project: source for `Sources/BaziChart/Resources/AreaIndex.json`

The upstream package describes the dataset as Chinese administrative-division codes based on GB/T 2260. BaziChart transforms the relevant province, city, district and code fields into a compact local JSON index.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to inclusion of the copyright and permission notice.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

## swift-testing

- Project: <https://github.com/swiftlang/swift-testing>
- Revision: `48a471ab313e858258ab0b9b0bf2cea55a50cefb`
- Scope: development and test builds only
- License: Apache License 2.0 with Runtime Library Exception

The project is not linked into release builds of the BaziChart application. Its complete license is included in [`THIRD_PARTY_SWIFT_TESTING_LICENSE`](THIRD_PARTY_SWIFT_TESTING_LICENSE).
