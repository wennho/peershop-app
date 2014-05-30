//
//  ItemCreationTVC.m
//  PeerShop
//
//  Created by Wen Hao on 5/27/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemCreationTVC.h"
#import "PeerShopInterface.h"

@interface ItemCreationTVC ()
@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemPrice;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;

@end

@implementation ItemCreationTVC

- (IBAction)create:(id)sender {
    NSDictionary *itemDict =
    @{
      ITEM_TITLE_KEY: self.itemTitle.text,
      ITEM_PRICE_KEY: self.itemPrice.text,
      ITEM_DESCRIPTION_KEY: self.itemDescription.text,
      };
}



@end
