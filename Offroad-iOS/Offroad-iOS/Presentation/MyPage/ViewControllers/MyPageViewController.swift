//
//  MyPageViewController.swift
//  Offroad-iOS
//
//  Created by 김민성 on 2024/07/15.
//

import UIKit

import RxSwift

final class MyPageViewController: OffroadTabBarViewController {
    
    //MARK: - Properties
    
    private let rootView = MyPageView()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAddTarget()
        getUserInfo()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        guard let offroadTabBarController = self.tabBarController as? OffroadTabBarController else { return }
        offroadTabBarController.showTabBarAnimation()
    }
}

extension MyPageViewController {
    
    // MARK: - Private Method
    
    private func setupAddTarget() {
        rootView.diaryButton.addTarget(self, action: #selector(myPageButtonTapped(_:)), for: .touchUpInside)
        rootView.characterButton.addTarget(self, action: #selector(myPageButtonTapped(_:)), for: .touchUpInside)
        rootView.couponButton.addTarget(self, action: #selector(myPageButtonTapped(_:)), for: .touchUpInside)
        rootView.titleButton.addTarget(self, action: #selector(myPageButtonTapped(_:)), for: .touchUpInside)
        rootView.settingButton.addTarget(self, action: #selector(myPageButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func getUserInfo() {
        view.startLoading()
        NetworkService.shared.profileService.getUserInfo { [weak self] response in
            guard let self else { return }
            self.view.stopLoading()
            switch response {
            case .success(let data):
                if let userInfoModel = data?.data {
                    self.rootView.bindData(data: userInfoModel)
                }
            default:
                break
            }
        }
    }
    
    private func bindData() {
        Observable.merge([MyInfoManager.shared.didSuccessAdventure.asObservable(),
                          MyInfoManager.shared.didChangeRepresentativeCharacter.asObservable(),
                          MyInfoManager.shared.shouldUpdateUserInfoData.asObservable()])
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.getUserInfo()
        }).disposed(by: disposeBag)
        
        #if DevTarget
        MyDiaryManager.shared.didCompleteCreateDiary
            .bind { _ in
                guard let offroadTabBarController = self.tabBarController as? OffroadTabBarController else { return }
                
                if offroadTabBarController.selectedIndex == 2 {
                    MyDiaryManager.shared.showCompleteCreateDiaryAlert(viewController: self)
                }
            }
            .disposed(by: disposeBag)
        #endif
    }
    
    // MARK: - @objc Func
        
    @objc private func myPageButtonTapped(_ sender: UIButton) {

        #if DevTarget
        if sender == rootView.diaryButton {
            let diaryViewController = DiaryViewController(shouldShowLatestDiary: false)
            diaryViewController.setupCustomBackButton(buttonTitle: "마이페이지")
            self.navigationController?.pushViewController(diaryViewController, animated: true)
        }
        #endif
        
        if sender == rootView.characterButton {
            let characterListViewController = CharacterListViewController()
            characterListViewController.setupCustomBackButton(buttonTitle: "마이페이지")
            self.navigationController?.pushViewController(characterListViewController, animated: true)
        }
        if sender == rootView.couponButton {
            let acquiredCouponViewController = CouponListViewController()
            self.navigationController?.pushViewController(acquiredCouponViewController, animated: true)
        }
        if sender == rootView.titleButton {
            let collectedTitlesViewController = CollectedTitlesViewController()
            self.navigationController?.pushViewController(collectedTitlesViewController, animated: true)
        }
        if sender == rootView.settingButton {
            let settingViewController = SettingViewController()
            self.navigationController?.pushViewController(settingViewController, animated: true)
            
        }
    }
}
