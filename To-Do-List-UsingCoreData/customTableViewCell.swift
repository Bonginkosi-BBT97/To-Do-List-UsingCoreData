//
//  customViewCellTableViewCell.swift
//  To-Do-List-UsingCoreData
//
//  Created by Bonginkosi Tshabalala on 2022/08/31.
//

import UIKit

protocol isChecked {
    func toggleIsComplete ( for cell: UITableViewCell)
}


class customTableViewCell: UITableViewCell {

    var isCompleteDelegate: isChecked?
    
    @IBOutlet weak var isDone:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(isMarked: Bool){
        if isMarked {
            
            isDone.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            
        }else {
            
            isDone.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }
    @IBAction func isDoneChecked(_ sender: Any){
        
        isCompleteDelegate?.toggleIsComplete(for: self)
        
        
    }
}
