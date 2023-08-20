//
//  HomeViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 13/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var buttonAging: UIButton!
    @IBOutlet weak var buttonCoreML: UIButton!
    
    @IBOutlet weak var buttonLiveFeed: UIButton!
    
    var modelArt: [ALArtModel] = [] {
        didSet {
            if self.modelArt.count > 0 {
                self.table.reloadData()
            }
        }
    }
    
    var modelArtSelected: ALArtModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        self.loadArtsResources()
        self.setupTableView()
        // Do any additional setup after loading the view.
    }


    private func prepareUI() {
        self.buttonAging.tag = 1
        self.buttonCoreML.tag = 1
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if let btn = sender as? UIButton {
            if btn.tag == 0 {
                self.loadCamera()
            } else {
                if btn == self.buttonAging {
                    let vc = NLPViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if btn == self.buttonCoreML {
                    self.loadGallery(type: .machineLearning)
                } else if btn == self.buttonLiveFeed {
                    let vc = LiveFeedViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
            }
        }
    }
    
    func loadCamera() {
        if let nav = self.navigationController {
            let router: ALRouterCamera = ALRouterCamera(nav: nav)
            router.create(cameraType: .normal, ads: .none)
        } else {
           
        }
    }
    
    func loadGallery(type: CameraType) {
        if let nav = self.navigationController {
            let router: ALRouterGallery = ALRouterGallery(nav: nav)
            router.create(cameraType: type, ads: .none, isFromCamera: false, modelArtSelected: self.modelArtSelected)
        } else {
        
        }
    }
    
    private func loadArtsResources() {
        guard let artModels = ALArtModel.initialize() else { return }
        self.modelArt = artModels
        //print("ART MODELS",modelArt)
    }
    
    private func setupTableView() {
        let nibToRegister = UINib(nibName: String(describing: CellFeatureTable.self), bundle: nil)
        self.table.register(nibToRegister, forCellReuseIdentifier: String(describing: CellFeatureTable.self))
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        self.table.backgroundView = bgView
        
        self.table.delegate = self
        self.table.dataSource = self
        self.table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.table.separatorInset = .zero
    }
}



//MARK: - TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modelArt.count //self.modelAlbum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellFeatureTable.self)) as! CellFeatureTable
        cell.selectionStyle = .none
        cell.labelTitle.text = self.modelArt[indexPath.row].image
        cell.imageIcon.image = self.modelArt[indexPath.row].previewImage
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.modelArtSelected = self.modelArt[indexPath.row]
        self.loadGallery(type: .art)
       
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 80.0
        return height
    }
    
    
}

