//
//  ItemCreationTVC.m
//  PeerShop
//
//  Created by Wen Hao on 5/27/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemCreationTVC.h"
#import "PeerShopInterface.h"
#import "ItemDetailViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ItemCreationTVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemPrice;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDictionary *uploadedItem;
@end

@implementation ItemCreationTVC

#define IMAGE_ROW 1
#define DESCRIPTION_ROW 4
#define PLACEHOLDER_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25]


- (void) viewDidLoad {
    [super viewDidLoad];
    [self setDescriptionPlaceholder];
    self.itemDescription.delegate = self;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PeerShopInterface ensureLogin:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.tabBarController.selectedIndex = 2;
}

- (void) setDescriptionPlaceholder
{
    self.itemDescription.text = @"Description";
    self.itemDescription.textColor = PLACEHOLDER_COLOR;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *) textView
{
    if ([self.itemDescription.textColor isEqual: PLACEHOLDER_COLOR]){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (self.itemDescription.text.length == 0){
        [self setDescriptionPlaceholder];
        [self.itemDescription resignFirstResponder];
    }
}

- (void) reset
{
    [self setDescriptionPlaceholder];
    self.itemPrice.text = nil;
    self.itemTitle.text = nil;
    self.imageView.image = [UIImage imageNamed:@"noImg"];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)create:(id)sender {
    NSDictionary *itemDict =
    @{
      ITEM_TITLE_KEY: self.itemTitle.text,
      ITEM_PRICE_KEY: self.itemPrice.text,
      ITEM_DESCRIPTION_KEY: self.itemDescription.text,
      };

    [PeerShopInterface uploadItem:itemDict withImage:self.imageView.image withCallback:^(NSArray *itemList) {
        self.uploadedItem = [itemList firstObject];
        [self reset];   // reset interface, so user can create a new item when returning from segue
        [self performSegueWithIdentifier:@"itemCreation" sender:self];
    }];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set up destination view controller
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[ItemDetailViewController class]]) {
        ItemDetailViewController *detailVC = (ItemDetailViewController *)destVC;
        detailVC.item = self.uploadedItem;
    }
}

- (IBAction)getGalleryImage:(id)sender {
    [self getImage:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
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
    } else if (indexPath.row == DESCRIPTION_ROW){
        return 150;
    } else {
        return self.tableView.rowHeight;
    }
}
@end
