//
//  SearchViewController.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/07/23.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import FirebaseDatabase

class SearchViewController: UIViewController {
    @IBOutlet var touchDismiss: UITapGestureRecognizer!
    
    let db = Database.database().reference().child("searchHistory")
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    // MVVM 패턴에서 벗어남...
    // 가지고 있는것 보다 ViewModel을 통해 가져오는게 좋다
    // 우선 이렇게 구현해본다.
    // 리팩토링 시 새로운 파일에 MVVM의 model로 구현 (데이터 저장소)
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
    // cell을 몇개 넘어오는지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // search 후 넘어온 영상의 개수
        return movies.count
    }
    
    // cell을 어떻게 표현할껀지
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // search view에 image을 올릴것이다. -- ResultCell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.item]
        // URLcomponets는 안됨
        let url = URL(string: movie.thumbnailPath)!
        // .image: Image , thumbnailPath: String
        // imagepath(string) -> image 변환
        // thumbnailPath 주소로 네트워킹해서 이미지를 가져온 후 이미지를 UIImage로 변환해줘야함
        // 대안 : 외부 코드 가져다 쓰기
        // SPM(Swift Package Manager), CocoaPods, Carthage -- 외부코드를 가져올 수 있다.
        
        cell.movieThumbnail.kf.setImage(with: url)
        
        // 시험용 cell - red
        //cell.backgroundColor = .red
        return cell
    }
}

class ResultCell: UICollectionViewCell {
    // cell의 image
    @IBOutlet weak var movieThumbnail: UIImageView!
}

// 클릭시 반응
extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        // movie item을 가지고 playerViewControler를 띄워서 전달해줘야한다
        // presenting player vc
        
        let movie = movies[indexPath.item]
        let url = URL(string: movie.previewURL)!
        let item = AVPlayerItem(url: url)
        
        // Player storyboard로 연결
        // bundle? -- 스토리 보드 파일과 관련 리소스가 포함 된 번들
        let sb = UIStoryboard(name: "Player", bundle: nil)
        
        // 왜 PlayerViewController 다운캐스팅할까?
        // -> sb가 UIViewController 타입이라 뷰에 쓸라면 PlayerViewController 다운캐스팅해서 맞춰야함
        let vc = sb.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        
        // default = modal
        vc.modalPresentationStyle = .fullScreen
        
        // PlayerViewController 타입으로 PlayerViewController에서 데이터(item)을 바꿔준다
        // item을 플레이어에 보여준다
        vc.simplePlayer.replaceCurrentItem(with: item)
        present(vc, animated: false, completion: nil)
    }
}

// 사이즈 조정
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    // 3열로 만들고 싶다.
    // 이미지 7 : 10 비율
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Min spacing -- 아이템간, 라인간 간격
        // Section Insets -- 뷰의 좌우, 위아래 간격
        // none으로 지정 후 우리가 직접 계산
        let margin: CGFloat = 8
        let itemSpacing: CGFloat = 10
        
//      Frame = 슈퍼뷰(상위뷰)의 좌표계에서 위치와 크기를 나타낸다.
//      Bounds = 자기자신의 좌표계에서 위치와 크기를 나타낸다.
        let width = (collectionView.bounds.width - margin * 2 - itemSpacing * 2) / 3
        let height = width * 10/7
        
        return CGSize(width: width, height: height)
    }
    
}


// Search Bar에서 일어나는 결과들을 ViewControler에게 위임시켜서 거기에 해당하는 일들을 ViewControler한태 담당시키기
// 클릭시 반응을 가지고 작업하려면 ViewControler와 Delegate 연결 시켜줘야함
// 검색어를 입력하고 버튼 클릭시 ViewController에게 알려주는 메소드
extension SearchViewController: UISearchBarDelegate {
    
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        //dismissKeyboard()
        self.view.endEditing(true)
    }

    
//  키보드 내리기
    private func dismissKeyboard(){
        // resign: 물러나다, 사임히다
        // 첫번째 응답에서 물러나라!
        searchBar.resignFirstResponder()
    }
    
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // 검색 시작
        
        // 클릭 시 키보드 내리기
        dismissKeyboard()
        
        // 검색어 있는지 없는지 확인
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {return}
        
        // 네트워킹을 통한 검색
        // - 목표: SearchTerm을 가지고 네트워킹을 통해 영화 검색
        // - 검색API 필요
        // - 결과를 받아올 모델 Movie, Response (아이튠즈API 사용)
        // - 결과를 받아와서 CollectionView로 표현
        
        // 디코딩 + 파싱 호출
        SearchAPI.search(searchTerm) { movies in
            // CollectionView로 표현하기
//            print("---> 몇개?:  \(movies.count), 첫 번째: \(movies)")
            // GCD
            DispatchQueue.main.async {
                self.movies = movies
                // 스레드 크레쉬 발생 -- Main Thread Checker: UI API called on a background thread
                self.resultCollectionView.reloadData()
                
                // rounded() -- 소수점 버리기
                let timestamp: Double = Date().timeIntervalSince1970.rounded()
                
                // database에 id랜덤으로 생성하고 값은 시간으로 넣기
                self.db.childByAutoId().setValue(["term": searchTerm, "timestamp": timestamp])
            }
            
        }
        
        //print("---> 검색어: \(searchBar)")
    }
}

// 검색 API
class SearchAPI {
    // type 메소드
    // @escaping -- completion안에 있는 코드 블럭이 메소드 밖에서 실행될 수도 있다.
    // 프로퍼티를 타입 자체와 연결할 수도 있다 이러한 프로퍼티를 Type Property라고 한다.
    // 타입 프로퍼티는 모든 타입이 사용할 수 있는 상수 프로퍼티(constants property) 또는 글로벌 변수 프로퍼티와 같이 특정 타입의 모든 인스턴스에 공통적인 값을 정의하는데 유용

    static func search (_ term: String, completion: @escaping ([Movie]) -> Void){
        let session = URLSession(configuration: .default)
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name: "media", value: "movie")
        let entityQuery = URLQueryItem(name: "entity", value: "movie")
        let termQuery = URLQueryItem(name: "term", value: term)
        
        urlComponents.queryItems?.append(mediaQuery)
        urlComponents.queryItems?.append(entityQuery)
        urlComponents.queryItems?.append(termQuery)
        
        let requestURL = urlComponents.url!
        
        let dataTask = session.dataTask(with: requestURL) { data, response, error in
            let successRange = 200..<300
            
            // response 메시지 안에서 statusCode 저장
            // statusCode가 200 ~ 299 안에 들어가는지 확인
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                return completion([])
            }
            
            guard let resultData = data else {
                return completion([])
            }
            
            // data -> [Movie] -- 데이터 타입을 바꾸기 위해서 파싱이 필요하다. (Codable)
            let movies = parseMovies(resultData)
            // 리턴이 void이므로 .. 이렇게 넘긴다
            completion(movies)
            
        }
        // 네트워킹 시작
        dataTask.resume()
    }
    
    static func parseMovies(_ data: Data) -> [Movie] {
        let decoder = JSONDecoder()
        
        // 파싱
        do {
            // Response.self movies 프로터티를 쓰기 위해서 .self 필요
            // Response() 객체를 만들어도됨
            // 즉 객체 !!
            // try -- 될 수도 있고 안될 수도 있으니까
            let response = try decoder.decode(Response.self, from: data)
            let movies = response.movies
            return movies
        } catch let error {
            print("---> parsing error: \(error.localizedDescription)")
            return []
            
        }
    }
}

struct Response: Codable{
    let resultCount: Int
    // results 배열을 Movie 구조체로 맞게 파싱
    let movies: [Movie]
    
    // Json 데이터를 쉽게 파싱하기 위해서 Codable
    enum CodingKeys: String, CodingKey {
        case resultCount
        case movies = "results"
    }
}

// search함수 외부에서 수행됨으로 @escaping 사용 그리고 외부 값 참조시에도 사용
struct Movie: Codable {
    // 필요한 것만 명시해보자
    let titles: String
    let director: String
    let thumbnailPath: String
    let previewURL: String
    
    enum CodingKeys: String, CodingKey {
        case titles = "trackName"
        case director = "artistName"
        case thumbnailPath = "artworkUrl100"
        case previewURL = "previewUrl"
        
    }
}
