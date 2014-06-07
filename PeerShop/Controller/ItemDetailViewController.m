//
//  ItemDetailViewController.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "PeerShopInterface.h"

@interface ItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *itemOwner;

@end

@implementation ItemDetailViewController

#define DESCRIPTION_ROW 2
#define IMAGE_ROW 0

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setupDetails];
}

- (void) setupDetails
{
    self.itemTitle.text = self.item.title;
    self.price.text = [@"$" stringByAppendingString:self.item.price];
    self.description.text = self.item.description;
    if ([self.description.text length] == 0){
        // at least have whitespace in the description so that height calculations work out
        self.description.text = @" ";
    }
    self.itemOwner.text = [NSString stringWithFormat:@"Posted by %@", self.item.user];
    [self startDownloadingImage];
}

- (void)startDownloadingImage
{

    if (self.item)
    {
        NSURL *imageURL = [NSURL URLWithString:self.item.imageUrl];
        [PeerShopInterface downloadThumbnail:imageURL
                                   withBlock:^(UIImage *img) {
                                       self.imageView.image = img;
                                       [self.tableView beginUpdates];
                                       [self.tableView endUpdates];
                                   }];
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == DESCRIPTION_ROW) {
        return self.description.intrinsicContentSize.height + 25;
    } else if (indexPath.row == IMAGE_ROW){
        if (self.imageView.image){
            CGSize size = self.imageView.image.size;
            CGFloat aspectRatio = size.height / size.width;
            return aspectRatio * self.imageView.frame.size.width;
        } else {
            return 50;
        }
    } else {
        return self.tableView.rowHeight;
    }
}

@end
