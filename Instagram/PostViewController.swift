//
//  PostViewController.swift
//  Instagram
//
//  Created by 中野誠 on 2021/09/21.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    

    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // 画像をJPEG形式に変換する
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        // 角丸にする ← original
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                // 投稿処理をキャンセルし、先頭画面に戻る
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            // FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            postRef.setData(postDic)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            // 投稿処理が完了したので先頭画面に戻る
           UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
                self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 受け取った画像をImageViewに設定する
        imageView.image = image
        
        // original　↓
        
        // UIImage インスタンスの生成
        // let image:UIImage = UIImage(named:"img")!
                
                // UIImageView 初期化
                let imageView = UIImageView(image:image)
                
                // 画面の横幅を取得
                let screenWidth:CGFloat = view.frame.size.width
                let screenHeight:CGFloat = view.frame.size.height
                
                // 画像の幅・高さの取得
                let imgWidth = image.size.width
                let imgHeight = image.size.height
                
                // 画像サイズをスクリーン幅に合わせる
                let scale = screenWidth / imgWidth * 0.9
                let rect:CGRect = CGRect(x:0, y:0,
                                  width:imgWidth*scale, height:imgHeight*scale)
         
                // ImageView frame をCGRectで作った矩形に合わせる
                imageView.frame = rect;
                
                // 画像の中心を画面の中心に設定
                imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
         
                // 角丸にする
                imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
                imageView.clipsToBounds = true
                
                // UIImageViewのインスタンスをビューに追加
                self.view.addSubview(imageView)
        

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
