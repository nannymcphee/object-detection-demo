//
//  LoadingView.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit
import SnapKit

class LoadingViewHelper {
    private static var vLoadingIndicator = LoadingView()
    static var isLoading: Bool {
        return vLoadingIndicator.isLoading
    }
    
    static func showLoading(in parentView: UIView,
                            loadingMessage: String? = nil) {
        guard !isLoading else { return }
        vLoadingIndicator.show(in: parentView, loadingMessage: loadingMessage)
    }
    
    static func hideLoading() {
        vLoadingIndicator.hideLoading()
    }
}

class LoadingView: UIView {
    // MARK: - UI Elements
    private lazy var indicatorContainer: UIStackView = {
        let indicatorContainer = UIStackView()
        indicatorContainer.axis = .vertical
        indicatorContainer.spacing = 8
        return indicatorContainer
    }()
    
    private lazy var lbMessage: UILabel = {
        let lbMessage = UILabel()
        lbMessage.textAlignment = .center
        lbMessage.lineBreakMode = .byWordWrapping
        lbMessage.numberOfLines = 0
        lbMessage.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbMessage.textColor = .black
        return lbMessage
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.color = .systemGray
        return indicator
    }()
    
    // MARK: - Variables
    public var isLoading: Bool {
        return loadingIndicator.isAnimating
    }

    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    public func show(in parentView: UIView,
                     loadingMessage: String?) {
        lbMessage.isHidden = loadingMessage.orEmpty.isEmpty
        lbMessage.text = loadingMessage
        loadingIndicator.startAnimating()
        
        parentView.addSubview(self)
//        window.isUserInteractionEnabled = false
        
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func hideLoading() {
        loadingIndicator.stopAnimating()
//        superview?.isUserInteractionEnabled = true
        self.removeFromSuperview()
    }
    
    // MARK: - Private functions
    private func setUpView() {
        addSubview(indicatorContainer)
        indicatorContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        indicatorContainer.addArrangedSubview(loadingIndicator)
        indicatorContainer.addArrangedSubview(lbMessage)
    }
}
