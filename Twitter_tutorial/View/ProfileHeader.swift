//
//  ProfileHeader.swift
//  Twitter_tutorial
//
//  Created by 梶村律太 on 2020/03/30.
//  Copyright © 2020 梶村律太. All rights reserved.
//

import UIKit

// how to delegate 1
protocol ProfileHeaderDelegate: class {
    func handleDismissal()
}

class ProfileHeader: UICollectionReusableView {
    // MARK: - Properties
    
    var user: User? {
        didSet{
            configure()
        }
    }
    weak var delegate: ProfileHeaderDelegate?
    
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor,left: view.leftAnchor,paddingTop: 42,paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        
        return view
        
    }()
    private lazy var backButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_white_24dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleProfileFollow), for: .touchUpInside)
        return button
        
        
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Eddie Brock"
        return label
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "hama"
        label.textColor = .lightGray
        return label
    }()
    private let bionameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.text = "This is user bio"
        return label
    }()
    private let underlineView :UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    private let followingLabel: UILabel = {
        let label = UILabel()
        let followTap = UIGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    private let followersLabel: UILabel = {
        let label = UILabel()
        let followTap = UIGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        
        addSubview(containerView)
        containerView.anchor(top:topAnchor,left: leftAnchor, right: rightAnchor,height: 108)
        
        addSubview(profileImageView)
        profileImageView.anchor(top:containerView.bottomAnchor,left: leftAnchor,
                                paddingTop: -24, paddingLeft: 8)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top:containerView.bottomAnchor,
                                       right: rightAnchor,paddingTop: 12,paddingRight: 12)
        
        
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,usernameLabel,bionameLabel])
        
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top:profileImageView.bottomAnchor,left: leftAnchor,
                                right: rightAnchor, paddingTop: 8,paddingLeft: 12,paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel,followersLabel])
        
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        addSubview(followStack)
        followStack.anchor(top:userDetailsStack.bottomAnchor,left: leftAnchor,paddingTop: 8,paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,height: 50)
        
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, width: frame.width / 3,height: 2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Selectors
    
    @objc func handleDismissal(){
        delegate?.handleDismissal()
    }
    @objc func handleProfileFollow(){
        
    }
    @objc func handleFollowingTapped(){
        
    }
    @objc func handleFollowersTapped(){
        
    }
// MARK: Helpers

    func configure(){
        guard let user = user else { return }
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        profileImageView.contentMode = .scaleAspectFill
        
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followerString
    }
}


// MARK: - ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate{
    func filterView(_ view: ProfileFilterView, didSelect indexPath: IndexPath) {
        guard let cell = view.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else{ return }
        let xPosition = cell.frame.origin.x
        UIView.animate(withDuration: 0.3){
            self.underlineView.frame.origin.x = xPosition
        }
    }
}