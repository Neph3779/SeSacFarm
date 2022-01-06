//
//  PostTableViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation
import RxSwift
import RxCocoa

final class PostTableViewModel {
    let posts = PublishSubject<[Post]>()

    init() {
    }
}
