//===----------------------------------------------------------------------===//
//
// This source file is part of the Soto for AWS open source project
//
// Copyright (c) 2017-2021 the Soto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Soto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension Templates {
    static let structTemplate = #"""
    {{%CONTENT_TYPE:TEXT}}
    {{! Template for a AWSShape }}
        public {{object}} {{name}}: {{shapeProtocol}} {
    {{#payload}}
            /// The key for the payload
            public static let _payloadPath: String = "{{.}}"
    {{/payload}}
    {{#options}}
            public static let _options: AWSShapeOptions = [{{.}}]
    {{/options}}
    {{#namespace}}
            public static let _xmlNamespace: String? = "{{.}}"
    {{/namespace}}
    {{! AWSShapeMember array }}
    {{#first(awsShapeMembers)}}
            public static var _encoding = [
    {{#awsShapeMembers}}
                AWSMemberEncoding(label: "{{name}}"{{#location}}, location: {{.}}{{/location}}){{^last()}}, {{/last()}}
    {{/awsShapeMembers}}
            ]
    {{/first(awsShapeMembers)}}
    {{#encoding}}
    {{! Is encoding a dictionary }}
    {{#key}}
            public struct {{name}}: DictionaryCoderProperties { static public let entry: String? = {{#entry}}"{{.}}"{{/entry}}{{^entry}}nil{{/entry}}; static public let key = "{{key}}"; static public let value = "{{value}}" }
    {{/key}}
    {{^key}}
            public struct {{name}}: ArrayCoderProperties { static public let member = "{{member}}" }
    {{/key}}
    {{/encoding}}

    {{! Member variables }}
    {{#members}}
    {{#comment}}
            /// {{.}}
    {{/comment}}
    {{#propertyWrapper}}
            {{.}}
    {{/propertyWrapper}}
            public {{#propertyWrapper}}var{{/propertyWrapper}}{{^propertyWrapper}}let{{/propertyWrapper}} {{variable}}: {{type}}
    {{/members}}

    {{! init() function }}
            public init({{#initParameters}}{{parameter}}: {{type}}{{#default}} = {{.}}{{/default}}{{^last()}}, {{/last()}}{{/initParameters}}) {
    {{#members}}
    {{^deprecated}}
                self.{{variable}} = {{variable}}
    {{/deprecated}}
    {{#deprecated}}
                self.{{variable}} = {{default}}
    {{/deprecated}}
    {{/members}}
            }
    {{! deprecated init() function }}
    {{^empty(deprecatedMembers)}}
            @available(*, deprecated, message:"Members {{#deprecatedMembers}}{{.}}{{^last()}}, {{/last()}}{{/deprecatedMembers}} have been deprecated")
            public init({{#members}}{{parameter}}: {{type}}{{#default}} = {{.}}{{/default}}{{^last()}}, {{/last()}}{{/members}}) {
    {{#members}}
                self.{{variable}} = {{variable}}
    {{/members}}
            }
    {{/empty(deprecatedMembers)}}
    {{! validate() function }}
    {{#first(validation)}}

            public func validate(name: String) throws {
    {{#validation}}
    {{#shape}}
                try self.{{name}}{{^required}}?{{/required}}.validate(name: "\(name).{{name}}")
    {{/shape}}
    {{! validate array members }}
    {{#.member}}
                try self.{{name}}{{^required}}?{{/required}}.forEach {
    {{#shape}}
                    try $0.validate(name: "\(name).{{name}}[]")
    {{/shape}}
    {{#sorted(reqs)}}
                    try validate($0, name: "{{name}}[]", parent: name, {{.key}}: {{.value}})
    {{/sorted(reqs)}}
                }
    {{/.member}}
    {{! validate dictionary members }}
    {{#withDictionaryContexts(.)}}
                try self.{{name}}{{^required}}?{{/required}}.forEach {
    {{#.keyValidation}}
    {{#shape}}
                    try $0.key.validate(name: "\(name).{{name}}.key")
    {{/shape}}
    {{#sorted(reqs)}}
                    try validate($0.key, name: "{{name}}.key", parent: name, {{.key}}: {{.value}})
    {{/sorted(reqs)}}
    {{/.keyValidation}}
    {{! validate dictionary values }}
    {{#.valueValidation}}
    {{#shape}}
                    try $0.value.validate(name: "\(name).{{name}}[\"\($0.key)\"]")
    {{/shape}}
    {{#sorted(reqs)}}
                    try validate($0.value, name: "{{name}}[\"\($0.key)\"]", parent: name, {{.key}}: {{.value}})
    {{/sorted(reqs)}}
    {{/.valueValidation}}
                }
    {{/withDictionaryContexts(.)}}
    {{! validate min,max,pattern }}
    {{#sorted(reqs)}}
                try self.validate(self.{{name}}, name: "{{name}}", parent: name, {{.key}}: {{.value}})
    {{/sorted(reqs)}}
    {{/validation}}
            }
    {{/first(validation)}}

    {{! CodingKeys enum }}
    {{#first(members)}}
    {{^first(codingKeys)}}
            private enum CodingKeys: CodingKey {}
    {{/first(codingKeys)}}
    {{#first(codingKeys)}}
            private enum CodingKeys: String, CodingKey {
    {{#codingKeys}}
    {{#duplicate}}
                case {{variable}} = "_{{codingKey}}" // TODO this is temporary measure for avoiding CodingKey duplication.
    {{/duplicate}}
    {{^duplicate}}
                case {{variable}} = "{{codingKey}}"
    {{/duplicate}}
    {{/codingKeys}}
            }
    {{/first(codingKeys)}}
    {{/first(members)}}
        }
    """#
}
