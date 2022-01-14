### 이번 과제에서 집중한 부분

- Rxswift의 사용
- MVVM을 통한 View, ViewModel의 분리 (화면 전환은 Coordinator 패턴을 차후에 학습 후 적용 예정)

### 페이지네이션과 관련한 내용

- 페이지네이션은 이전에도 몇차례 구현한 적이 있기에 이번과제에서는 생략하고 다른 파트에 더 집중했습니다.
- offest.y를 확인하여 일정 위치에 도달했을 때 새로운 데이터를 불러와서 cell을 추가해주는 것이 가장 잘 적용되었습니다. (tableview, collectionview delegate를 이용하는 방법은 불안정한 경우가 많았습니다.)
- rxswift를 안쓸때는 일정 위치에서 데이터를 불러오고 datasource에 데이터 추가, reload등의 과정이 동기적으로 이루어지는게 중요했지만 rx가 있으니 onNext이벤트로 datasource만 추가해줘도 잘 적용될 것입니다.

### 피드백을 받고 싶은 부분

- Rx를 처음 사용하다보니 더 좋은 방법이 있음에도 돌아가는 방법을 택한 경우가 많을 것 같습니다. 어색한 부분이 있다면 개선해볼 방법이나 키워드 등을 알려주시면 감사하겠습니다.

- layout을 잡을때 label의 intrinsic contentsize를 고려해서 만드는 편인데 기본 text가 없을때 intrinsic contentsize가 적용되지 않아 height가 0이 되는 문제가 있는데 이를 해결하기 위해 default값을 항상 넣어주고 있습니다. 이 부분을 다른 방식으로 해결해볼 수 있을까요?

  ```swift
  struct Post: Codable {
      //...
  
      static let `default` = Post(id: 0, text: "게시글", user: User(id: 0, userName: "익명"),
                                  comments: [], createdDate: "") 
                                  // layout이 깨지는 것을 방지하기 위해 반드시 label을 위한 default값이 필요
  
      //...
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          guard let headerView = tableView
                  .dequeueReusableHeaderFooterView(withIdentifier: PostDetailHeaderView.reuseIdentifier)
                  as? PostDetailHeaderView else { return UIView() }
  
          postDetailViewModel.post
              .observe(on: MainScheduler.instance)
              .catchAndReturn(Post.default) // error발생시 default 값을 넣어주는 모습
              .subscribe(onNext: { post in
                  headerView.setValues(userName: post.user.userName, date: post.createdDate,
                                       description: post.text, replyCount: post.comments.count)
              }).disposed(by: disposeBag)
  
          return headerView
      }
  ```

- cell binding작업과 onError 이벤트 처리를 동시에 할수는 없을까요? 방법을 찾지 못해 다음과 같이 따로 적어주었습니다.

  ```swift
  postDetailViewModel.comments
              .observe(on: MainScheduler.instance)
              .catchAndReturn([])
              .bind(to: tableView.rx.items(
                  cellIdentifier: "tableViewCell",
                  cellType: UITableViewCell.self)
              ) { _, model, cell in
                  var content = cell.defaultContentConfiguration()
                  content.text = model.user.userName
                  content.secondaryText = model.comment
                  cell.contentConfiguration = content
  
                  if SesacNetwork.shared.id == model.user.id {
                      let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                      button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
                      button.tintColor = .black
                      button.rx.tap.subscribe(onNext: {
                          self.commentEditButtonTapped(comment: model)
                      }).disposed(by: self.disposeBag)
                      cell.accessoryView = button
                  } else {
                      cell.accessoryView = nil
                  }
              }
              .disposed(by: disposeBag)
  
          postDetailViewModel.comments
              .subscribe(onError: { error in
                  self.loadingErrorAction(error, errorTitle: "댓글 불러오기 실패")
              })
              .disposed(by: disposeBag)
  
          postDetailViewModel.post
              .subscribe(onError: { error in
                  self.loadingErrorAction(error, errorTitle: "게시글 불러오기 실패")
              })
              .disposed(by: disposeBag)
  ```

  

  - p.s. 수정 버튼은 자신이 작성한 경우에만 띄워주는 것이 더 자연스럽다 생각하여서 유저를 대조한 뒤 필요한 경우에만 accessoryView에 넣어주었습니다.
  - tableView.rx.itemAccessoryButtonTapped 이벤트를 구독해보았지만 accessoryType = .detailButton인 경우를 제외하고는 이벤트가 전달되지 않아서 버튼을 따로 만든 뒤, 그 버튼을 구독하도록 만들었습니다. 더 좋은 해결방법이 있다면 알려주시면 감사하겠습니다!
