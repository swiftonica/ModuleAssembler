/// This Library is full opensource and free to use
///
///     version: 1.0
///
///     License: MIT License
///
/// Created by Jeytery for iOS community with love

public protocol Initable {
    init()
}

public extension Initable {
    init() {
        self.init()
    }
}

public protocol AssemblableView: Initable {
    associatedtype EventOutputType
    var eventOutput: EventOutputType { get set }
}

public protocol AssemblablePresenter: Initable {
    associatedtype EventOutputHandlerType
    associatedtype ViewInterfaceContractType
    
    var eventOutputHandler: EventOutputHandlerType { get }
    var interfaceContract: ViewInterfaceContractType! { get set }
}

public extension AssemblablePresenter {
    var eventOutputHandler: EventOutputHandlerType? {
        return self as? EventOutputHandlerType
    }
}

public protocol Assemblable {
    associatedtype ViewType: AssemblableView
    associatedtype PresenterType: AssemblablePresenter
    associatedtype PublicInterfaceType
    
    var module: Module<
        ViewType, PresenterType, PublicInterfaceType
    > {
        get
    }
    
    var view: ViewType { get }
    var presenter: PresenterType { get }
    var publicInterface: PublicInterfaceType? { get }
}

public extension Assemblable {
    var module: Module<
        ViewType, PresenterType, PublicInterfaceType
    > {
        var view = self.view
        var presenter = self.presenter
        if let eventOutput = presenter.eventOutputHandler as? ViewType.EventOutputType {
            view.eventOutput = eventOutput
        }
        if let interfaceContract = view as? PresenterType.ViewInterfaceContractType {
            presenter.interfaceContract = interfaceContract
        }
        return Module(
            view: view,
            presenter: presenter,
            publicInterface: self.publicInterface
        )
    }
}

public extension Assemblable {
    var view: ViewType {
        return ViewType()
    }
    
    var presenter: PresenterType {
        return PresenterType()
    }
    
    var publicInterface: PublicInterfaceType? {
        return view as? PublicInterfaceType
    }
}

public class Assembler<
    ViewType: AssemblableView,
    PresenterType: AssemblablePresenter,
    PublicInterfaceType
>: Assemblable {
    
}

public struct Module<ViewType, PresenterType, PublicInterfaceType> {
    public let view: ViewType
    public let presenter: PresenterType
    public let publicInterface: PublicInterfaceType?
}

