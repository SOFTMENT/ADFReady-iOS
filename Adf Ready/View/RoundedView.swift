//
//  RoundedView.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 15/11/24.
//

import UIKit

class RoundedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.masksToBounds = true
       
    }
}
