import SwiftUI
import UIKit

struct ContentView: View {
    // 내 정보가 들어있는 url
    var url = URL(string: "https://api.github.com/users/MoonGoon72")
    @State var user: User? = nil
    var body: some View {
        VStack(alignment: .leading) {
            if let user = user {
                Text("\(user.id.description)")
                Text("\(user.login)")
                /// 버튼을 누르면 프로필 이미지 url로 이동!
                /// 추후에는 UIImage를 사용하여 url 이미지를 받아와서 켜지도록 하면 좋을 듯
                Button {
                    if let imgUrl = URL(string: user.avatar_url) {
                        UIApplication.shared.open(imgUrl, options: [:])
                    }
                } label: {
                    Text("Profile")
                }
                
            } else {
                ProgressView()
            }
            
            Button {
                let request = URLRequest(url: url!)
                // var task = 를 넣어주는 경우도 있다
                // URLSession이 request를 통한 data와, 응답 번호, 에러여부 반환
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    // error 발생시 종료
                    // response가 200~300 사이여야 잘 온 것
                    let successRange = 200..<300
                    guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                            print("Error occur: \(String(describing: error))")
                        return
                    }
                    
                    guard let data = data else {
                        print("invalid Data")
                        return
                    }
                    // JSONDecoder()를 미리 선언해놓음
                    let decoder = JSONDecoder()
                    do {
                        // data로부터 User 형태로 디코딩
                        let response = try decoder.decode(User.self, from: data)
                        // 응답이 길어지면 멈춰있으니 DispatchQueue 사용
                        DispatchQueue.main.async {
                            self.user = response
                        }
                    } catch {
                        print(error)
                    }
                }
                .resume()
            } label: {
                Text("Send")
            }
        }
        
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self]  in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
