//
//  ViewController.swift
//  ChatBot_Sample
//
//  Created by Santhosh K on 12/01/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickHere(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatBotViewController")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func onClickHereTestVC(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestViewController")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}

