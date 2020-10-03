//===----------------------------------------------------------------------===//
//
// This source file is part of the Soto for AWS open source project
//
// Copyright (c) 2020 the Soto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Soto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

struct DeprecatedTrait: Trait {
    static let name = "smithy.api#deprecated"
    let message: String
    let since: String
}

struct Documentation: StringTrait {
    static let name = "smithy.api#documentation"
    let string: String
}
