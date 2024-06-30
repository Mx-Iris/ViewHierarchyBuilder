//
//  ViewHierarchy.swift
//  CodeOrganizerUI
//
//  Created by JH on 2023/7/12.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public typealias CocoaView = NSView
public typealias CocoaViewController = NSViewController
public typealias CocoaLayoutGuide = NSLayoutGuide
#elseif canImport(UIKit) && !os(watchOS)
import UIKit

public typealias CocoaView = UIView
public typealias CocoaViewController = UIViewController
public typealias CocoaLayoutGuide = UILayoutGuide
#else

#error("Unsupported platform")

#endif

#if !os(watchOS)
public protocol ViewHierarchyComponent {
    func attach(to view: CocoaView)
}

@resultBuilder
public enum ViewHierarchyBuilder {
    public static func buildBlock() -> [ViewHierarchyComponent] {
        []
    }

    public static func buildBlock(_ components: [ViewHierarchyComponent]...) -> [ViewHierarchyComponent] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: [ViewHierarchyComponent]?) -> [ViewHierarchyComponent] {
        component ?? []
    }

    public static func buildEither(second component: [ViewHierarchyComponent]?) -> [ViewHierarchyComponent] {
        component ?? []
    }

    public static func buildOptional(_ component: [ViewHierarchyComponent]?) -> [ViewHierarchyComponent] {
        component ?? []
    }

    public static func buildExpression(_ expression: [ViewHierarchyComponent]?) -> [ViewHierarchyComponent] {
        expression ?? []
    }

    public static func buildExpression(_ expression: ViewHierarchyComponent?) -> [ViewHierarchyComponent] {
        expression.map { [$0] } ?? []
    }

    public static func buildArray(_ components: [[ViewHierarchyComponent]]) -> [ViewHierarchyComponent] {
        components.flatMap { $0 }
    }
}

@dynamicMemberLookup
public struct ViewItem<View: CocoaView>: ViewHierarchyComponent {
    private let view: View

    @discardableResult
    public init(_ view: View) {
        self.view = view
    }

    @discardableResult
    public init(_ view: View, @ViewHierarchyBuilder builder: () -> [ViewHierarchyComponent]) {
        self.view = view
        builder().forEach { $0.attach(to: view) }
    }

    public func attach(to view: CocoaView) {
        view.addSubview(self.view)
    }

    public subscript<Member>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Member>) -> Member {
        set {
            view[keyPath: keyPath] = newValue
        }
        get {
            view[keyPath: keyPath]
        }
    }

    public subscript<Member>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Member>) -> (Member) -> Self {
        return { newMember in
            view[keyPath: keyPath] = newMember
            return self
        }
    }
}

public struct LayoutGuideItem: ViewHierarchyComponent {
    private let layoutGuide: CocoaLayoutGuide

    public init(_ layoutGuide: CocoaLayoutGuide) {
        self.layoutGuide = layoutGuide
    }

    public func attach(to view: CocoaView) {
        view.addLayoutGuide(layoutGuide)
    }
}

@dynamicMemberLookup
public struct ControllerItem<ViewController: CocoaViewController>: ViewHierarchyComponent {
    private let controller: ViewController

    @discardableResult
    public init(_ controller: ViewController) {
        self.controller = controller
    }

    @discardableResult
    public init(_ controller: ViewController, @ViewHierarchyBuilder builder: () -> [ViewHierarchyComponent]) {
        self.controller = controller
        builder().forEach { $0.attach(to: controller.view) }
    }

    public func attach(to view: CocoaView) {
        view.addSubview(controller.view)
    }

    public subscript<Member>(dynamicMember keyPath: ReferenceWritableKeyPath<ViewController, Member>) -> Member {
        set {
            controller[keyPath: keyPath] = newValue
        }
        get {
            controller[keyPath: keyPath]
        }
    }

    public subscript<Member>(dynamicMember keyPath: ReferenceWritableKeyPath<ViewController, Member>) -> (Member) -> Self {
        return { newMember in
            controller[keyPath: keyPath] = newMember
            return self
        }
    }
}

extension CocoaView: ViewHierarchyComponent {
    public func attach(to view: CocoaView) {
        view.addSubview(self)
    }

    @discardableResult
    public func hierarchy(@ViewHierarchyBuilder _ builder: () -> [ViewHierarchyComponent]) -> Self {
        builder().forEach { $0.attach(to: self) }
        return self
    }
}

extension CocoaLayoutGuide: ViewHierarchyComponent {
    public func attach(to view: CocoaView) {
        view.addLayoutGuide(self)
    }
}

extension CocoaViewController: ViewHierarchyComponent {
    public func attach(to view: CocoaView) {
        view.addSubview(self.view)
    }

    @discardableResult
    public func hierarchy(@ViewHierarchyBuilder _ builder: () -> [ViewHierarchyComponent]) -> Self {
        builder().forEach { $0.attach(to: self.view) }
        return self
    }
}

//protocol ViewHierarchyBuildable {
//    var __buildRootView: CocoaView { get }
//}
//
//extension CocoaViewController: ViewHierarchyBuildable {
//    var __buildRootView: CocoaView { view }
//}
//
//extension CocoaView: ViewHierarchyBuildable {
//    var __buildRootView: CocoaView { self }
//}
//
//extension ViewHierarchyBuildable {
//    public func build(@ViewHierarchyBuilder builder: () -> [ViewHierarchyComponent]) {
//        builder().forEach { $0.attach(to: __buildRootView) }
//    }
//}
#endif
