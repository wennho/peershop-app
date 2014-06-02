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

@interface ItemCreationTVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemPrice;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ItemCreationTVC

#define IMAGE_ROW 4
#define PLACEHOLDER_COLOR [UIColor colorWithRed:155/255.0f green:176/255.0f blue:201/255.0f alpha:1.0f]


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

- (void) textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0){
        [self setDescriptionPlaceholder];
        [textView resignFirstResponder];
    }
}

- (IBAction)create:(id)sender {
    NSDictionary *itemDict =
    @{
      ITEM_TITLE_KEY: self.itemTitle.text,
      ITEM_PRICE_KEY: self.itemPrice.text,
      ITEM_DESCRIPTION_KEY: self.itemDescription.text,
      };

    [PeerShopInterface uploadItem:itemDict withImage:self.imageView.image];
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
    } else {
        return self.tableView.rowHeight;
    }
}
@end
