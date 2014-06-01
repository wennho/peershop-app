//
//  ItemCreationTVC.m
//  PeerShop
//
//  Created by Wen Hao on 5/27/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemCreationTVC.h"
#import "PeerShopInterface.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ItemCreationTVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemPrice;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ItemCreationTVC

#define IMAGE_ROW 4

- (void) viewDidLoad {
    [super viewDidLoad];
    [PeerShopInterface login];
}

- (IBAction)create:(id)sender {
    NSDictionary *itemDict =
    @{
      ITEM_TITLE_KEY: self.itemTitle.text,
      ITEM_PRICE_KEY: self.itemPrice.text,
      ITEM_DESCRIPTION_KEY: self.itemDescription.text,
      ITEM_IMAGE_KEY:self.imageView.image,
      };

}

- (IBAction)getGalleryImage:(id)sender {
    [self getImage:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)takePhoto:(id)sender {
    [self getImage:UIImagePickerControllerSourceTypeCamera];
}

-(void) getImage:(UIImagePickerControllerSourceType) sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == IMAGE_ROW){
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
